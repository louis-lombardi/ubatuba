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

  def call_verification
     call_template("HX61bc68a7fe6766b9d5bbf88a6c759974")
  end

  def call_not_understood
     call_template("HX8bdbe7315ad3fff47c73822ea5af70d4")
  end

  def call_agreement
     call_template("HX6e3f39ca51b19d7ec820efa3c372547f")
  end

  def call_new_chat_not_understood
     call_template("HX8bdbe7315ad3fff47c73822ea5af70d4")
  end

  def call_new_chat_success
     call_template("HX6e3f39ca51b19d7ec820efa3c372547f")
  end

  def call_new_chat_error
     call_template("HX6e3f39ca51b19d7ec820efa3c372547f")
  end

  def call_template(csid)
      @client = Twilio::REST::Client.new(@sid,@token)
      message = @client.messages.create(content_sid: csid, from: "whatsapp:+12727700781",to: "#{@phone}")
  end
end
