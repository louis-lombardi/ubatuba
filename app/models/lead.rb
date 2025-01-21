class Lead < ApplicationRecord
    after_create :send_email

    def send_email
        EmailService.send_emails(self)
    end
end