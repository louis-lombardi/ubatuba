class EmailService

    def self.send_emails(lead)
        Mailjet.configure do |config|
            config.api_key = "73f68d9ad301ffd718a36a57fdc596ec"
            config.secret_key = "4b591b3dac7f33a0f3a56459f44d0bfd"
            config.api_version = "v3.1"
        end
        send_customer(lead)
        send_seller(lead)
    end

    def self.send_customer(lead)
        Mailjet::Send.create(messages: [{
            'From'=> {
                'Email'=> 'louis.lombardi@place-trip.com',
                'Name'=> 'Place Trip'
            },
            'To'=> [{
                'Email'=> lead.email, 
                'Name'=> 'Customer'
            }],
            'Subject': "Sua viagem personalizada está a caminho!",
            'HtmlPart'=> customer_text(lead),
        }])
    end

    def self.send_seller(lead)
        Mailjet::Send.create(messages: [{
            'From'=> {
                'Email'=> 'louis.lombardi@place-trip.com',
                'Name'=> 'Place Trip'
            },
            'To'=> [{
                'Email'=> 'louis.lombardi@place-trip.com', 
                'Name'=> 'Louis PlaceTrip'
            }],
            'Subject': "Nova solicitação de viagem via PlaceTrip",
            'HtmlPart'=> seller_text(lead),
        }])
    end

    def self.customer_text(lead)
        "<!DOCTYPE html>
        <html lang=\"pt-BR\">
        <head>
        <meta charset=\"UTF-8\">
        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
        <title>Resumo da Sua Viagem</title>
        </head>
        <body style=\"font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 20px; background-color: #f4f4f9;\">
        <div style=\"max-width: 600px; margin: 0 auto; background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);\">
        <h1 style=\"color: #21c2d1;\">Olá,</h1>
        <p>Estamos super animados por ajudar a planejar sua próxima aventura! Aqui está um resumo das informações que você nos enviou. Assim, podemos garantir que sua experiência será exatamente como você deseja:</p>
        <h2 style=\"color: #21c2d1;\">Detalhes da sua viagem</h2>
        <ul>
        <li><strong>Local de partida:</strong> #{lead.origin}</li>
        <li><strong>Destino e tipo de viagem:</strong> #{lead.destination}</li>
        <li><strong>Número de pessoas:</strong> #{lead.amount_people - lead.amount_children} adulto(s), #{lead.amount_children} criança(s)</li>
        <li><strong>Orçamento estimado:</strong> R$ #{lead.budget}</li>
        <li><strong>Duração desejada:</strong> #{lead.duration} dias</li>
        <li><strong>Período para a viagem:</strong> #{lead.dates}</li>
        <li><strong>Nível de hospedagem:</strong> #{lead.accomodations}</li>
        <li><strong>Itens incluídos no pacote:</strong>
        <ul>
        <li>Voos: #{lead.want_flight ? 'Sim' : 'Não'}</li>
        <li>Transfers: #{lead.want_transfer ? 'Sim' : 'Não'}</li>
        </ul>
        </li>
        <li><strong>Atividades desejadas:</strong> #{lead.activities}</li>
        <li><strong>Outros comentários:</strong> #{lead.additional_informations.length < 2 ? 'N/A' : lead.additional_informations}</li>
        </ul>
        <h2 style=\"color: #21c2d1;\">O que acontece agora?</h2>
        <p>Compartilhamos essas informações com agências de viagens parceiras que vão preparar opções sob medida para você. Fique de olho no seu <strong>canal de comunicação preferido</strong> — você receberá novidades em breve!</p>
        <p>Agradecemos por ter escolhido a <strong>PlaceTrip</strong> para planejar sua próxima viagem. Faremos o possível para tornar sua viagem inesquecível! 😊</p>
        <p>Se tiver alguma dúvida ou quiser ajustar alguma informação, é só responder este email. Estamos aqui para ajudar!</p>
        <p>Até logo e boa viagem,</p>
        <p><strong>Equipe PlaceTrip</strong><br>
        <a href=\"https://place-trip.com\" style=\"color: #21c2d1; text-decoration: none;\">place-trip.com</a></p>
        </div>
        </body>
        </html>"
    end

    def self.seller_text(lead)
        "<!DOCTYPE html>
        <html lang=\"pt-BR\">
        <head>
        <meta charset=\"UTF-8\">
        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
        <title>Nova Solicitação de Viagem</title>
        </head>
        <body style=\"font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 20px; background-color: #f4f4f9;\">
        <div style=\"max-width: 600px; margin: 0 auto; background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);\">
        <h1 style=\"color: #21c2d1;\">Olá,</h1>
        <p>Recebemos uma nova solicitação de viagem gerada pela PlaceTrip. Abaixo estão todas as informações fornecidas pelo visitante para que você possa entender melhor suas necessidades e oferecer uma proposta personalizada.</p>
        <h2 style=\"color: #21c2d1;\">Informações de contato do visitante</h2>
        <ul>
        <li><strong>Email:</strong> #{lead.email}</li>
        <li><strong>Local de partida:</strong> #{lead.origin}</li>
        <li><strong>Destino e tipo de viagem:</strong> #{lead.destination}</li>
        <li><strong>Número de pessoas:</strong> #{lead.amount_people - lead.amount_children} adulto(s), #{lead.amount_children} criança(s)</li>
        <li><strong>Orçamento estimado:</strong> R$ #{lead.budget}</li>
        <li><strong>Duração desejada:</strong> #{lead.duration} dias</li>
        <li><strong>Período para a viagem:</strong> #{lead.dates}</li>
        <li><strong>Nível de hospedagem:</strong> #{lead.accomodations}</li>
        <li><strong>Itens incluídos no pacote:</strong>
        <ul>
        <li>Voos: #{lead.want_flight ? 'Sim' : 'Não'}</li>
        <li>Transfers: #{lead.want_transfer ? 'Sim' : 'Não'}</li>
        </ul>
        </li>
        <li><strong>Atividades desejadas:</strong> #{lead.activities}</li>
        </ul>
        <p>Outros comentários: #{lead.additional_informations.length < 2 ? 'N/A' : lead.additional_informations}</p>
        <p>Estamos à disposição para qualquer esclarecimento. Não hesite em entrar em contato diretamente com o visitante para apresentar uma proposta.</p>
        <p>Atenciosamente,</p>
        <p><strong>Equipe PlaceTrip</strong><br>
        <a href=\"https://place-trip.com\" style=\"color: #21c2d1; text-decoration: none;\">place-trip.com</a></p>
        </div>
        </body>
        </html>"
    end
end

