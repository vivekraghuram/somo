require 'twilio-ruby'
class TwilioController < ApplicationController

  #before_action :get_twilio_client

  def start
    form = Form.find(params[:form])
    params[:phone]
  end
  
  def recieve
    if params[:SmsStatus] == "received"
      response_body = params[:Body]
      response_number = params[:From]
      self.send(response_number, response_body)
    end
  end

  def send(number, body)
    # Real Credits
    account_sid = 'ACc5f882e1e4d40eb6e854830f67a20643' 
    auth_token = '6e6cdc5b174ee4a0ae0ef8ac7854a2d6'
   
    # Test creds
    #account_sid = 'AC6016613046133ebde46069a02581cc7e'
    #auth_token = '8a45795f032cb5fd0b5f0567b58951be' 
     
    # set up a client to talk to the Twilio REST API 
    @client = Twilio::REST::Client.new account_sid, auth_token 
     
    @client.account.messages.create({
      from: '+14085164672',
      to: number,
      body: body
    })
  end

  private

  #def get_twilio_client
  #  @client = Twilio::REST::Client.new 'ACc5f882e1e4d40eb6e854830f67a20643', '6e6cdc5b174ee4a0ae0ef8ac7854a2d6'
  #  debugger
  #end
end
