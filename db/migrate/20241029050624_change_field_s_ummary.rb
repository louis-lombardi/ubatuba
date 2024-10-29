class ChangeFieldSUmmary < ActiveRecord::Migration[5.2]
  def change
    change_column(:packages, :summary, :text)
  end
end
