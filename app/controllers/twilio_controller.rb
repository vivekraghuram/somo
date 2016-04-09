require 'twilio-ruby'
class TwilioController < ApplicationController
  @twilio_number = '+14085164672'
  @survey_start = 'Welcome to Somo surveys: reply BEGIN to start, and END to stop'

  def start
    form = Form.find(params[:form])
    self.send(params[:phone], @survey_start)
    TwilioState.create(phone: params[:phone], state: TwilioState.states[:welcome])
  end
  
  def status
    puts params
  end

  def recieve
    if params[:SmsStatus] == "received"
      response_body = params[:Body]
      response_number = params[:From]
      self.send(response_number, response_body)
    else
      puts "was not recieved"
    end
  end

  def send(number, body)
    # Real Creds
    account_sid = 'ACc5f882e1e4d40eb6e854830f67a20643' 
    auth_token = '6e6cdc5b174ee4a0ae0ef8ac7854a2d6'
   
    # Test creds
    #account_sid = 'AC6016613046133ebde46069a02581cc7e'
    #auth_token = '8a45795f032cb5fd0b5f0567b58951be' 
     
    @client = Twilio::REST::Client.new account_sid, auth_token  
    @client.account.messages.create({
      from: @twilio_number,
      to: number,
      body: body
    })
  end
end
