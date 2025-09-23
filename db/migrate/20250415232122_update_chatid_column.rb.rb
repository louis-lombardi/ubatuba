=begin
class UpdateChatidColumn < ActiveRecord::Migration[5.2]
    def change
      change_column(:leads, :chat_id, :string)
    end
end
=end
