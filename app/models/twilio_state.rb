class TwilioState < ActiveRecord::Base
  belongs_to :form
  belongs_to :question

  @@twilio_number = '+14083421089'
  @@account_sid = 'AC997d895e03da78468d7a954541370e32'
  @@auth_token = '62282bd011e55c6ec20c8b51e91764bf'

  def send_twilio(body)
    @client = Twilio::REST::Client.new @@account_sid, @@auth_token
    @client.account.messages.create({
      from: @@twilio_number,
      to: phone,
      body: body
    })
  end

  def self.resend
    TwilioState.all.each do |ts|
      if ts.sent_last_hour
        ts.sent_last_hour = false
      else
        ts.send_twilio(ts.question.construct_text(ts.alpha_index)) rescue nil
        ts.sent_last_hour = true
      end
      ts.save
    end
  end
end
