class EmailService

    def self.send_email(lead)
        Mailjet.configure do |config|
            config.api_key = "73f68d9ad301ffd718a36a57fdc596ec"
            config.secret_key = "4b591b3dac7f33a0f3a56459f44d0bfd"
            config.api_version = "v3.1"
        end
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
            'TextPart'=> customer_text(lead),
        }])
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
            'TextPart'=> seller_text(lead),
        }])
    end

    def self.customer_text(lead)
"Olá,
Estamos super animados por ajudar a planejar sua próxima aventura! Aqui está um resumo das informações que você nos enviou. Assim, podemos garantir que sua experiência será exatamente como você deseja:
<strong> Detalhes da sua viagem </strong>
#{travel_summary(lead)}
O que acontece agora?
Compartilhamos essas informações com agências de viagens parceiras que vão
preparar opções sob medida para você. Fique de olho no seu [canal de comunicação
preferido] — você receberá novidades em breve!
Agradecemos por escolher a PlaceTrip para planejar sua próxima viagem. Vamos
fazer o possível para que seja inesquecível! ��
Se tiver alguma dúvida ou quiser ajustar alguma informação, é só responder este
email. Estamos aqui para ajudar!
Até logo e boa viagem,
Equipe PlaceTrip
place-trip.com"
    end

    def self.seller_text(lead)
"Olá,
Recebemos uma nova solicitação de viagem gerada pela PlaceTrip. Abaixo estão todas as informações fornecidas pelo visitante para que você possa entender melhor suas necessidades e oferecer uma proposta personalizada.
<strong> Informações de contato do visitante </strong>
- Email: #{lead.email}
#{travel_summary(lead)}
Estamos à disposição para qualquer esclarecimento. Não hesite em entrar em contato diretamente com o visitante para apresentar uma proposta.
Atenciosamente,
Equipe PlaceTrip
place-trip.com"
    end


def self.travel_summary(lead)
"- Local de partida: #{lead.origin}
- Destino e tipo de viagem: #{lead.destination}
- Número de pessoas: #{lead.amount_people - lead.amount_children} adulto(s), #{lead.amount_children} criança(s)
- Orçamento estimado: R$ #{lead.budget}
- Duração desejada: #{lead.duration} dias
- Período para a viagem: #{lead.dates}
- Nível de hospedagem: #{lead.accomodation}
- Itens incluídos no pacote:
    * Voos: #{lead.want_flights ? 'Sim' : 'Não'}
    * Transfers: #{lead.want_transfers ? 'Sim' : 'Não'}
- Atividades desejadas: #{lead.activities}
- Outros comentários: #{lead.additional_informations}"
end


end