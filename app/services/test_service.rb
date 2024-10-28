class EmailService < ::ApplicationService

    def self.send_mail(emails)
        Mailjet.configure do |config|
            config.api_key = "73f68d9ad301ffd718a36a57fdc596ec"
            config.secret_key = "4b591b3dac7f33a0f3a56459f44d0bfd"
            config.api_version = "v3.1"
        end
        mailjet_response = Mailjet::Send.create(messages: [{
            'From'=> {
                'Email'=> 'louis.lombardi@place-trip.com',
                'Name'=> 'Place Trip'
            },
            'To'=> [{
                'Email'=> '68louis68@gmail.com', 
                'Name'=> 'Louis'
            }],
            'Subject': "Important Lead",
            'TextPart'=> "Here re the infos:.....",
        }])
        mailjet_response
    end
end