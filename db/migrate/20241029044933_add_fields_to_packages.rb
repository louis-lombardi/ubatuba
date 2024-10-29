class AddFieldsToPackages < ActiveRecord::Migration[5.2]
  def change
    add_column :packages, :supplier, :string
    rename_column :packages, :location, :destination
    add_column :packages, :name, :string
    add_column :packages, :id_post, :integer
    add_column :packages, :id_url, :string
    add_column :packages, :status, :string
    add_column :packages, :url, :string
    add_column :packages, :img_url, :string
    add_column :packages, :duration_days, :integer
    add_column :packages, :price_min_brl, :float
    add_column :packages, :price_max_brl, :float
    add_column :packages, :accept_parcels, :boolean
    add_column :packages, :parcels_amount, :integer
    add_column :packages, :summary, :string
    add_column :packages, :departure_location, :string
    add_column :packages, :is_flexible, :boolean
    add_column :packages, :validity_start, :timestamp
    add_column :packages, :validity_end, :timestamp
    add_column :packages, :themes, :string
    add_column :packages, :services, :string
  end
end
