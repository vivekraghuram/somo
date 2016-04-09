class CreateForms < ActiveRecord::Migration
  def change
    create_table :forms do |t|
      t.string :name
      t.text :intro

      t.timestamps null: false
    end
  end
end
