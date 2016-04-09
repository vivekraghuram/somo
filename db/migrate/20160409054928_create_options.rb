class CreateOptions < ActiveRecord::Migration
  def change
    create_table :options do |t|
      t.string :value
      t.references :question, index: true
      t.integer :next

      t.timestamps null: false
    end
    add_foreign_key :options, :questions
  end
end
