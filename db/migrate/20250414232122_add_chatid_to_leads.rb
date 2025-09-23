=begin
class AddChatidToLeads < ActiveRecord::Migration[5.2]
    def change
          add_column :leads, :chat_id, :integer
    end
end
=end
  
