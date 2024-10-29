class EmailService

    def self.send_email(lead)
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
            'TextPart'=> body_text(lead),
        }])
        mailjet_response
    end

    def self.body_text(lead)
"Bom dia, tudo bem?

Segue um novo contato que deseja uma proposta de viagem!

Informação contato:

#{"Nome: #{lead.name}" if lead.name}
#{"E-mail: #{lead.email}" if lead.email}
#{"Tel: #{lead.phone}" if lead.phone}


Informação viagem:

O cliente esta interessado para uma viagem para #{lead.destination}.
#{"Ele deseja sair de #{lead.current_location}" if lead.current_location}
#{"Datas desejadas: de #{lead.start_date} até #{lead.end_date}" if lead.start_date && lead.end_date}
#{"Numero de pessoas: #{lead.travellers_amount}" if lead.travellers_amount}
#{"O orçamento desejado é: #{lead.budget}" if lead.budget}
#{"Os serviços desejados sao: #{lead.services}" if lead.services}
#{""}

Page do viagem: Viva Porto Seguro
Operador: Viagens Promo

Obrigado
PlaceTrip
Mais informações: contact@place-trip.com"
    end
end