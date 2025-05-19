class CreateColumnProfile < ActiveRecord::Migration[6.0]
  def change
    add_column :leads, :profile, :string
  end
end
