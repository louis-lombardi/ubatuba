class GptController < ApplicationController

    def send_gpt
        uri = URI.parse('https://api.openai.com/v1/chat/completions')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri.request_uri)
        request.body= params.to_json
        request['Content-Type'] = 'application/json'
        request['Authorization'] = "Bearer #{Rails.application.credentials.gpt_key}"
        response = http.request(request)
        render json: response.body
    end
end

