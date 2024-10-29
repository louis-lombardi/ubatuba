class CreateTableLeads < ActiveRecord::Migration[5.2]
  def change
    create_table :leads do |t|
      t.string :destination
      t.string :current_location
      t.timestamp :start_date
      t.timestamp :end_date
      t.integer :travellers_amount
      t.string :phone
      t.string :email
      t.string :name
      t.float :budget
      t.string :services
      t.string :themes
      t.integer :duration

      t.timestamps
    end
  end
end