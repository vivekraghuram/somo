class DeleteOptionsNextField < ActiveRecord::Migration
  def change
    remove_column :options, :next, :integer
  end
end
