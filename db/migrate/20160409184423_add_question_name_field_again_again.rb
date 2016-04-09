class AddQuestionNameFieldAgainAgain < ActiveRecord::Migration
  def change
    add_column :questions, :qname, :string
  end
end
