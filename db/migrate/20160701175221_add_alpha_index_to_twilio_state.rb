class AddAlphaIndexToTwilioState < ActiveRecord::Migration
  def change
    add_column :twilio_states, :alpha_index, :integer
  end
end
