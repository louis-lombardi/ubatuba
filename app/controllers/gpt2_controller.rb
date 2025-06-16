class Gpt2Controller < ApplicationController

  def receive_whats
    user = WhatsappUser.find_by(number: number)
    if user.nil?
      user = WhatsappUser.create(number: number, current_chat_id: SecureRandom.uuid, last_connect: DateTime.now)
      WhatsappService.new(welcome_message, number).call
    end
    chat_id = user.current_chat_id
    if ChatMessage.where(chat_id: chat_id, role: 'authorized').any? || ChatMessage.where(chat_id: chat_id, role: 'not_authorized').any?
      if content =="Começar novo atendimento"
        user.delete
        user = WhatsappUser.create(number: number, current_chat_id: SecureRandom.uuid, last_connect: DateTime.now)
        WhatsappService.new(new_chat_message, number).call
      else
        WhatsappService.new(nil, number).call_new_chat_not_understood
      end
    elsif ChatMessage.where(chat_id: chat_id, role: 'end').any? && !ChatMessage.where(chat_id: chat_id, role: 'partial_no').any?
      if content.in?(%w[sim SIM Sim simm ok OK Ok])
       ChatMessage.create(chat_id: chat_id, role: 'authorized')
        assistant_content = send_request(body_hash_lead(chat_id))
        begin
          lead_params = assistant_content.split('```')[1].gsub("\n",'').gsub('json','')
        rescue
          lead_params = assistant_content
        end
        Lead.create!(JSON.parse(lead_params).merge(chat_id: chat_id, profile: current_profile, whats_number: number.split(':')[1]).as_json)
        WhatsappService.new(nil, number).call_new_chat_success
      elsif content.in?(%w[nao Nao NAO Não não NÃO])
        ChatMessage.create(chat_id: chat_id, role: 'partial_no') 
        WhatsappService.new(nil, number).call_verification
      else
        WhatsappService.new(nil, number).call_not_understood
      end
    elsif ChatMessage.where(chat_id: chat_id, role: 'end').any? && ChatMessage.where(chat_id: chat_id, role: 'partial_no').any?
      if content.in?(%w[sim SIM Sim simm ok OK Ok])
       ChatMessage.create(chat_id: chat_id, role: 'authorized')
        assistant_content = send_request(body_hash_lead(chat_id))
        begin
          lead_params = assistant_content.split('```')[1].gsub("\n",'').gsub('json','')
        rescue
          lead_params = assistant_content
        end
        Lead.create!(JSON.parse(lead_params).merge(chat_id: chat_id, profile: current_profile, whats_number: number.split(':')[1]).as_json)
        WhatsappService.new(nil, number).call_new_chat_success
      elsif content.in?(%w[nao Nao NAO Não não NÃO])
        ChatMessage.create(chat_id: chat_id, role: 'not_authorized') 
        WhatsappService.new(nil, number).call_new_chat_error
      else
        WhatsappService.new(nil, number).call_not_understood
      end
    else
      ChatMessage.create(chat_id: chat_id, content: content, role: 'user')
      assitant_content = send_request(body_hash_response(chat_id))
      if assitant_content.include?("ENDING_CHAT")
        ChatMessage.create(chat_id: chat_id, role: 'end') 
        WhatsappService.new(nil, number).call_agreement
      else
        ChatMessage.create(chat_id: chat_id, content: assitant_content.gsub(/[^\u0000-\u00FF]/, ''), role: 'assistant')
        WhatsappService.new(assitant_content, number).call
      end
    end
    render json: {success: true}
  rescue => e
      Log.create(source: 'gpt_controller#send_gpt_whats', backtrace: e.backtrace, error: e, additional_info: params.to_json)
    render json: {success: false}
  end

  def number
    params[:From]
  end

  def content
    params[:Body]
  end

  def welcome_message
    "Olá! 🌟 Eu sou TAIS, o Sistema de Inteligência Artificial de Viagens da PlaceTrip. Estou aqui para te ajudar a criar a viagem dos seus sonhos! Podemos explorar pacotes prontos ou, se você preferir, posso criar uma solicitação personalizada para você. Para começar, me conte: qual é o seu destino e que tipo de viagem você está pensando? (praia, romântica, esportiva, cultural, etc.) Estou aqui para ajudar!"
  end

  def agreement_message
    "Muito obrigado! Agora, temos a sua permissão para enviar suas informaçoes aos nossos parceiros?"
  end

  def send_request(body_hash)
    uri = URI.parse('https://api.openai.com/v1/chat/completions')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body= body_hash.to_json
    request['Content-Type'] = 'application/json'
    request['Authorization'] = "Bearer #{Rails.application.credentials.gpt_key}"
    response = http.request(request)
    #Log.create(source: 'gpt_response', additional_info: response.body)
    JSON.parse(response.body)['choices'].first['message']['content']
  end

  def body_hash_lead(chat_id)
    body_hash = {
        model: "gpt-4o-mini",
        messages: [prescript, first_message, second_message] 
    }
    ChatMessage.where(chat_id: chat_id).where.not(role: ['config_pro','config_traveller','end','authorized','not_authorized', 'partial_no']).order(:created_at).each do |message|
        body_hash[:messages].push({
            content: message.content,
            role: message.role
        })
    end
    body_hash[:messages].push(sumup_message)
    body_hash
  end

  def body_hash_response(chat_id)
    body_hash = {
        model: "gpt-4o-mini",
        messages: [prescript, first_message, second_message] 
    }
    ChatMessage.where(chat_id: chat_id).where.not(role: ['config_pro','config_traveller','end','authorized','not_authorized', 'partial_no']).order(:created_at).each do |message|
        body_hash[:messages].push({
            content: message.content,
            role: message.role
        })
    end
    body_hash[:messages].push({
        content: content,
        role: 'user'
    })
    body_hash
  end


  def prescript
    {role: 'system', content: "Your name is TAIS (which stands for Travel Artificial Intelligence System), an assistant for creating trips on the PlaceTrip website (Place-trip.com). Place-trip.com allows users to discover ready-to-go travel packages (pacote) and connects them with travel agents to receive travel offers. If no corresponding package is available on the site, you will create a custom request and send it to a partner agency.
    Your responses must be in Brazilian Portuguese, with a tone that is light, serious, and respectful. You can include a touch of humor. The conversation should flow naturally and show interest in the user, but your answers should be short. It should not feel like a cold series of questions or a survey. Limit yourself to asking for one piece of information per message.
    You are prohibited to use \"**\" formatings to indicate string text, instead use HTML <strong> tags.
    
    **********
    You should initiate the conversation by introducing yourself (mentioning PlaceTrip and the meaning of TAIS), explaining your purpose, and letting the user know that a request can be sent at any time. However, the more information you receive, the better the response will be.
    **********
    
    Your goal is to work with the user to build the trip they would like to take, gathering the following information:
    First you have to identify the destination (in case of a country, offer some regions or cities of interest to afine the wish of the cliente). You should also give the main points of interest of the destination with short descriptions. If the client express constraints, you have to offer coherente destinations.
    the type of trip (beach, romantic, sports, cultural, etc.)
    ask for confirmation of you understanding.
    The number of people (and if there are any children)
    The duration of the trip
    The budget of the trip (pay attention, the user might inform the budget per person, per day, per person and date, or total for the whole duration and all the people. If you have a doubt on what he meant, just ask for confiration.
    Ask from where he leaves.
    Then, delve deeper into:
    Desired dates
    Type of accommodations
    Whether they want plane tickets and transfers included in the offer, 
    Ask if we want you add on-site activities, and if so, what type of activities. Make some propositions
    If the user gives you some information and answers before you ask them, no need to ask the questions again, just consider you have already the info
    If you haven't obtained certain information, try to ask for it once more but only once (except for the number of people, the budget, the destination and the type of trip, these are mandatory) .
    
    When you have gathered all the information, ask the user if there is something he wants to add.
    
    A demand is impossible to respond if the date of departure is in less than one week, if the duration is less than 2 days and if the budget is incoherente with the demande. In these cases, you have to ask what you should change.
    
    If the customer is willing to go to france and mentioned wines, winery or oenology, and ONLY in that case, instead of asking permission to send the information, answer to him with following html code: <a href=\"https://place-trip.com/tour-item/bordeaux-gastronomico-id10502/\"><strong>Bordeaux, coração gastronômico - Placetrip</strong></a><\br>
    <img src=\"https://place-trip.com/wp-content/uploads/2024/10/vineyard-5810650-550x550.jpg\" class=\"logo\"><\br> and tell him that it might interest him (it is actualy the link for a package in France to discover wines).
    If the contrary (the customer does not want to go to france and exeprience something about wine),follow these steps:
    1° summarize the proposal by detailing the request's key points. In this summary, please use HTML tags to organize the bullet points and highlight the main pieces of information. This summary should only appear once, at the end of the conversation.
    2° gather the user’s email. If they refuse to provide it, explain why it’s necessary to fulfill their request but reassure them that you remain available whenever they wish. 
    3° Once you have gathered the email address, say exactly \"ENDING_CHAT\". This must be exactly the response you send, as this will be used as a trigger in our system.
    You are prohibited from discussing other languages, stating that you are a version of ChatGPT, responding to non-travel-related topics, or mentioning competitor sites of PlaceTrip.    "}
  end

  def second_message
    {role: 'assistant', content: "Olá! 🌟 Eu sou TAIS, o Sistema de Inteligência Artificial de Viagens do PlaceTrip. Estou aqui para te ajudar a criar a viagem dos seus sonhos! Podemos explorar pacotes prontos ou, se você preferir, posso criar uma solicitação personalizada para você. Para começar, me conte: qual é o seu destino e que tipo de viagem você está pensando? (Praia, romântica, esportiva, cultural, etc.) Estou aqui para ajudar! 🌍✈️"}
  end

  def first_message
    { role: 'user', content: "ola!"}
  end

  def sumup_message
    {role: 'system', content: "Now, please sum up the responses in a json containing following fields (in no case you will include comments inside the json):
    - email (string)
    - origin (string)
    - destination (string)
    - dates (string)
    - want_flight (boolean)
    -want_transfer (boolean)
    - accomodations (string)
    - activities (string)
    - amount_people (int, including children)
    - amount_children (int)
    -budget (int, must be the total budget, in BRL. Important: You must pay attention if the user passed the budget 'per day', 'per person', or 'per day and person'. In that cases, you have to do the necessary computations to get the total budget for the whole duration and all the travelers )
    Also, if the budget was passed in another currency, convert it to BRL using following exchange rates:
    1 USD = 5,7 BRL
    1 EUR = 6,1 BRL
    1 GBP = 7,4 BRL
    1 JPY = 0,038 BRL
    1 CHF = 6,43 BRL
    1 CAD = 3,96 BRL
    1 AUD = 3,57 BRL
    1 CNY = 0,79 BRL
    1 INR = 0,066 BRL
    1 RUB = 0,068 BRL)
    
    -duration (int, in days, you can convert from weeks or month if needed)
    -additional_informations (string)"}
  end

  def new_chat_message
    "Olá novamente! 🌟 Me conte: qual é o seu destino e que tipo de viagem você está pensando? (Praia, romântica, esportiva, cultural, etc.) Estou aqui para ajudar! 🌍✈️"
  end
end

