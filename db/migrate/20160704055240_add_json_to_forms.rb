class AddJsonToForms < ActiveRecord::Migration
  def change
    add_column :forms, :json, :string
  end
end
