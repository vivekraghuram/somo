require 'twilio-ruby'

class TwilioResponsesController < ApplicationController
  include GoogleDriveStorage

  skip_before_action :verify_authenticity_token

  @@twilio_number = '+14083421089'
  @@account_sid = 'AC997d895e03da78468d7a954541370e32'
  @@auth_token = '62282bd011e55c6ec20c8b51e91764bf'

  @@survey_start = 'Welcome to Somo surveys: reply BEGIN to start, and FINISH to stop'
  @@survey_end = 'Thank you for using Somo surveys'
  @@survey_over = 'Your survey is over'

  @@DEBUG = true

  def new
    @f = Form.find_by_id(params[:form_id])
  end

  def start
    form = Form.find(params[:form].to_i).prepare

    phone = params[:phone]
    if phone =~ /,/ # Comma Separated
      numbers = phone.gsub(/[^0-9,]/,"").split(",")
    else # Intelligent matching
      phone_regex = /\+?(9[976]\d|8[987530]\d|6[987]\d|5[90]\d|42\d|3[875]\d|2[98654321]\d|9[8543210]|8[6421]|6[6543210]|5[87654321]|4[987654310]|3[9643210]|2[70]|7|1)[^0-9]*\d\d[^0-9]*\d?[^0-9]*\d?[^0-9]*\d?[^0-9]*\d?[^0-9 ]?\d?[^0-9 ]?\d?[^0-9 ]?\d?[^0-9 ]?\d?[^0-9 ]?\d?[^0-9 ]?\d?[^0-9 ]?\d?[^0-9 ]?\d?[^0-9 ]?\d?/
      numbers = phone.to_enum(:scan, phone_regex).map {$&}.map {|n| n.gsub(/[^0-9]/,"")}
    end
    numbers.each do |num|
      start_survey(form, "+" + num)
    end
  end

  def receive
    if params[:SmsStatus] == "received"
      response_number = params[:From]
      response_body = params[:Body].strip.upcase
      if @@DEBUG
        puts "reponse number: " + response_number.to_s + " body: " + response_body.to_s
      end
      ts = TwilioState.find_by phone: response_number
      if ts.blank? # received Response without Number found
        ts = TwilioState.create(phone: response_number, state: 0, form: Form.last, alpha_index: 0)
        response_body = @@survey_start
        if @@DEBUG
          puts "Could not find number: " + response_number.to_s + " in db"
        end
      else
        if ts.state == 2 # END
          response_body = @@survey_over
          if @@DEBUG
            puts "Survey in finished state"
          end
        elsif response_body == "FINISH"
          response_body = @@survey_end
          if @@DEBUG
            puts "Survey Completed via FINISH Command"
          end
        elsif ts.state == 0 # WELCOME
          if response_body == "BEGIN"
            ts.state = 1
            ts.question = Question.find(ts.form.first_question)
            ts.save
            ts.send_twilio(ts.form.intro)
            response_body = ts.question.construct_text(ts.alpha_index)
            if @@DEBUG
              puts "Sending First Question"
            end
          else # USER welcomed and !start
            response_body = @@survey_start
            if @@DEBUG
              puts "User responsed to Survey Start with something other than Begin"
            end
          end
        elsif ts.state == 1 # QUESTIONING
          if ts.question.valid_answer(response_body, ts.alpha_index)
            answer = ts.question.get_answer(response_body, ts)
            drive_save(ts.form, ts.question, answer, response_number)
            if ts.question.nil?
              response_body = @@survey_end
              ts.state = 2
              ts.save
              if @@DEBUG
                puts "Survey Complete"
              end
            else
              response_body = ts.question.construct_text(ts.alpha_index)
              if @@DEBUG
                puts "Survey Continues with question: " + ts.question.id.to_s
              end
            end
            ts.save
          else # Doesn't answer question RESEND
            response_body = ts.question.construct_text(ts.alpha_index)
            if @@DEBUG
              puts "Invalid response resending question: " + ts.question.id.to_s
            end
          end
        else # state not in enum
          puts "ERROR: unknown state (someone is monkeying around in the db)"
        end
      end
      ts.send_twilio(response_body)
    else # Twilio api returned not received response
      puts "ERROR: was not received - invalid twilio response"
    end
    render :nothing => true
  end

  private

  def start_survey(form, phone)
    if TwilioState.find_by(phone: phone).blank?
      ts = TwilioState.create(phone: phone, state: 0, form: form, alpha_index: 0)
      render :nothing => true
    else
      ts = TwilioState.find_by(phone: phone)
      render text: "You've already sent to this number"
    end
    ts.send_twilio(@@survey_start)
  end
end
