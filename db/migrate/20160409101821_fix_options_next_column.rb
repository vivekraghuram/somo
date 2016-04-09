class FixOptionsNextColumn < ActiveRecord::Migration
  def change
    rename_column :options, :next, :nextQuestion
  end
end
