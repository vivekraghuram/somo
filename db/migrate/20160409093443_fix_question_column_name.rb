class FixQuestionColumnName < ActiveRecord::Migration
  def change
    rename_column :questions, :type, :questionType
  end
end
