class AddOptionsNextField < ActiveRecord::Migration
  def change
    add_column :options, :next, :string
  end
end
