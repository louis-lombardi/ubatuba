class CreateTableLeads < ActiveRecord::Migration[5.2]
    def change
      create_table :chat_messages do |t|
        t.string :chat_id
        t.text :content
        t.string :type

        t.timestamps
      end
    end
  end