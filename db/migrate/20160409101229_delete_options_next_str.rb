class DeleteOptionsNextStr < ActiveRecord::Migration
  def change
    remove_column :options, :next, :string
  end
end
