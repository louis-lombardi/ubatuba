class CreateUser < ActiveRecord::Migration[5.2]
  def change
    create_table :whatsapp_users do |t|
      t.string :number
      t.string :current_chat_id
      t.timestamp :last_connect

      t.timestamps
    end
  end
end

