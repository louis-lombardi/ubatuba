class CreatePackages < ActiveRecord::Migration[5.2]
    def change
      change_column(:leads, :activities, :text)
      change_column(:leads, :additional_informations, :text)
    end
  end
  