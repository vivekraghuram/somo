class AddSentLastHourToTwilioState < ActiveRecord::Migration
  def change
    add_column :twilio_states, :sent_last_hour, :boolean, default: true
  end
end
