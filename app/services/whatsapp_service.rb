class WhatsappService

  def initialize(text, phone)
    @text = text
    @phone = phone
    @sid = Rails.application.credentials.twilio_sid
    @token = Rails.application.credentials.twilio_token
  end

  def call
    @client = Twilio::REST::Client.new(@sid,@token)
    message = @client.messages.create(body: @text, from: "whatsapp:+12727700781",to: "#{@phone}")
  end
end
