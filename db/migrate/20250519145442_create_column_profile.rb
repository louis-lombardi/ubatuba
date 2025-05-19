class CreateColumnProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :profile, :string
  end
end
