class RecreateLogs < ActiveRecord::Migration[5.2]
    def change
      rename_table :logs, :logs_old
      create_table :logs do |t|
        t.string :source
        t.text :error
        t.text :backtrace
        t.json :additional_info
  
        t.timestamps
      end 
    end
end
