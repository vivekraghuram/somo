class AddFormToQuestion < ActiveRecord::Migration
  def change
    add_reference :questions, :form, index: true
    add_foreign_key :questions, :forms
  end
end
