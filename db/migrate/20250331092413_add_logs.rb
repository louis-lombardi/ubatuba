class AddLogs < ActiveRecord::Migration[5.2]
    def change
      create_table :logs do |t|
        t.string :source
        t.string :error
        t.text :backtrace
        t.jsonb :additional_info
  
        t.timestamps
      end
    end
  end
  