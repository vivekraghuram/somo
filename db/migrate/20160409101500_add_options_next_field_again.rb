class AddOptionsNextFieldAgain < ActiveRecord::Migration
  def change
    add_column :options, :next, :integer
  end
end
