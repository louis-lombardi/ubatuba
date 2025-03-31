class GptController < ApplicationController

    def send_gpt
        ip_address = request_headers["X-Forwarded-For"]
        return if Log.where("created_at >= ?", 1.hour.ago).where(source: "ip_count").where(error: ip_address).count > 2000
        
        Log.create(source: "ip_count", error: ip_address)
        if params[:user_response] == "no"
            ChatMessage.create(chat_id: chat_id, role: 'not_authorized')
            render json: {success: true}
        elsif params[:user_response] == "yes"
            ChatMessage.create(chat_id: chat_id, role: 'authorized')
            assistant_content = send_request(body_hash_lead)
            begin
                lead_params = assistant_content.split('```')[1].gsub("\n",'').gsub('json','')
            rescue
                lead_params = assistant_content
            end
            Lead.create!(JSON.parse(lead_params))
            render json: {success: true}
        else
            ChatMessage.create(chat_id: chat_id, content: content, role: 'user')
            assitant_content = send_request(body_hash_response)
            if assitant_content.include?("ENDING_CHAT")
                ChatMessage.create(chat_id: chat_id, role: 'end') 
                render json: {content: 'ENDING_CHAT'}
            else
                ChatMessage.create(chat_id: chat_id, content: assitant_content.gsub(/[^\u0000-\u00FF]/, ''), role: 'assistant')
                render json: {content: assitant_content}
            end
        end
    rescue => e
        Log.create(source: 'gpt_controller#send_gpt', backtrace: e.backtrace, error: e, additional_info: params.to_json)
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
        JSON.parse(response.body)['choices'].first['message']['content']
    end

    def body_hash_lead
        body_hash = {
            model: "gpt-4o-mini",
            messages: [prescript, first_message, second_message] 
        }
        ChatMessage.where(chat_id: chat_id).where.not(role: ['end','authorized','not_authorized']).order(:created_at).each do |message|
            body_hash[:messages].push({
                content: message.content,
                role: message.role
            })
        end
        body_hash[:messages].push(sumup_message)
        body_hash
    end

    def body_hash_response
        body_hash = {
            model: "gpt-4o-mini",
            messages: [prescript, first_message, second_message] 
        }
        ChatMessage.where(chat_id: chat_id).where.not(role: ['end','authorized','not_authorized']).order(:created_at).each do |message|
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
        The duration and total budget of the trip
        Ask from where he leaves.
        Then, delve deeper into:
        Desired dates
        Type of accommodations
        Whether they want plane tickets and transfers included in the offer, 
        Ask if we want you add on-site activities, and if so, what type of activities. Make some propositions
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
        -budget (int, must be the total budget, in BRL. Important: if the budget was passed in dollars, convert it to BRL using an exchange rate of 5.6. You must also pay attention if the user passed the budget per day, per person, or per day and person. In that cases, you have to do the necessary computations to get the total budget for the whole duration and all the travelers )
        -duration (int, in days, you can convert from weeks or month if needed)
        -additional_informations (string)"}
    end

    def chat_id
        @chat_id ||= params[:chat_id]
    end

    def content
        params[:content]
    end

end
