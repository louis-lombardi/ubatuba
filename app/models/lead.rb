class Lead < ApplicationRecord
    after_create :send_email

    def send_email
        EmailService.send_email(self)
    end
end