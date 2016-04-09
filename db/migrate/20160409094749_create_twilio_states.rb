class CreateTwilioStates < ActiveRecord::Migration
  def change
    create_table :twilio_states do |t|
      t.references :form, index: true
      t.references :question, index: true
      t.string :phone
      t.integer :state

      t.timestamps null: false
    end
    add_foreign_key :twilio_states, :forms
    add_foreign_key :twilio_states, :questions
  end
end
