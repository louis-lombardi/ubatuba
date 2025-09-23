=begin
class CreateColumnWhat < ActiveRecord::Migration[5.2]
    def change
      add_column :leads, :whats_number, :string
    end
  end
=end
