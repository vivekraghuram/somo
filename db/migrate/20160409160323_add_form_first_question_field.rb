class AddFormFirstQuestionField < ActiveRecord::Migration
  def change
    add_column :forms, :firstQuestion, :integer
  end
end
