class ChangeColumnsToSnakeCase < ActiveRecord::Migration
  def change
    rename_column :forms, :firstQuestion, :first_question
    rename_column :options, :nextQuestion, :next_question
    rename_column :questions, :questionType, :question_type
  end
end
