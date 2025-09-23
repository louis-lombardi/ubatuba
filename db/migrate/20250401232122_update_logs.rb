=begin
class UpdateLogs < ActiveRecord::Migration[5.2]
    def change
      change_column(:logs, :error, :text)
      change_column(:leads, :backtrace, :text)
    end
end
=end
  
