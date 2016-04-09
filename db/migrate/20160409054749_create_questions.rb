class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :type
      t.string :name
      t.string :text

      t.timestamps null: false
    end
  end
end
