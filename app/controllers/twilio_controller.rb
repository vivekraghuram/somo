require 'twilio-ruby'
require "google/api_client"
require "google_drive"

class TwilioController < ApplicationController
  skip_before_action :verify_authenticity_token

  @@twilio_number = '+14085164672'
  @@account_sid = 'ACc5f882e1e4d40eb6e854830f67a20643' 
  @@auth_token = '6e6cdc5b174ee4a0ae0ef8ac7854a2d6'

  @@survey_start = 'Welcome to Somo surveys: reply BEGIN to start, and END to stop'
  @@survey_end = 'Thank you for using Somo surveys'
 
  @@abc = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

  def start
    form = Form.find(params[:form].to_i)
    send_twilio(("+" + params[:phone]), @@survey_start)
    TwilioState.create(phone: ("+" + params[:phone]), state: TwilioState.states[:welcome], form: form)
  end
  
  def status
    puts params
  end

  def recieve
    if params[:SmsStatus] == "received"
      response_number = params[:From]
      response_body = params[:Body].strip.upcase
      ts = TwilioState.find_by phone: response_number
        
      if !ts.blank? and         
        if response_body == "END" or ts.state != TwilioState.states[:stopped] # END
          ts.state = TwilioState.states[:stopped]
          ts.save
          response_body = @@survey_end 
        elsif ts.state == TwilioState.states[:welcome] # WELCOME
          if response_body == "BEGIN"
            ts.state = TwilioState.states[:questioning]
            ts.question = Question.find_by(name: "1", form: ts.form)
            ts.save
            response_body = construct_question(ts.question)  
          else # USER welcomed and !start
            response_body = @@survey_start
          end
        elsif ts.state == # QUESTIONING
          if answers_question(response_body, ts.question)
            if ts.question.questionType == "short_answer" # short answer value blank
              opt = Option.find_by(question: ts.question, value: "")
            else
              opt = Option.find_by(question: ts.question, value: response_body)
            end
            nextQ = opt.nextQuestion
            if nextQ.nil? # at END of survey
              ts.state = TwilioState.states[:stopped]
              ts.save
              response_body = @@survey_end 
            else 
              ts.question = nextQ
              ts.save
              response_body = construct_question(ts.question)
            end
          else # RESEND
            response_body = construct_question(ts.question)
          end
        else # state not in enum
          puts "error unknown state"
        end
      else # Number not found - DEFAULT last created form
        response_body = @@survey_start
        TwilioState.create(phone: response_number, state: TwilioState.states[:questioning], form: Form.last)
      end
      send_twilio(response_number, response_body)
    else # Twilio api returned not recieved response
      puts "was not recieved"
    end
  end

  def construct_question(question) # returns body of message
    abc = @@abc.dup
    response = question.text + "\n"
    if question.questionType != "short_answer"
      question.options.each do |option|
        response += "\n" + abc[0] + option.value
        abc[0] = "" # poo
      end
      if question.questionType == "multiple_choice" || question.questionType == "conditional"
        response += "\n\nRespond with a single letter ex: B" 
      elsif question.questionType == "checkbox"
        response += "\n\nRespond with comma separated letter ex: A,C"
      else
        puts "unknown question type"
      end
    else
      response += "\n\nRespond with a short answer"
    end
    return response
  end

  def answers_question(question, value) # TODO: STORES RESULTS if True
    abc = @@abc.dup
    if question.questionType == "short_answer"
      # to sheets
      #selected = value
      return true
    elsif question.questionType == "checkbox"
      value.strip.upcase.split(",").each do |choice|
        index = abc.index(value.strip)
        if index.nil? or (index + 1) > questions.options.length
          return false
        end
        #selected = question.options.at(index)
        # to sheets
        return true
      end
    elsif question.questionType == "multiple_choice" || question.questionType == "conditional"
      index = abc.index(value.strip.upcase)
      if index.nil? or (index + 1) > question.options.length
        return false
      end
      # to sheets
      return true
    end
    return false
  end

  def drive_save(form, question, phone_number)
    
  end

  def drive_init #(form)
    form = Form.find(1)
    directory = Rails.root.join('tmp').to_s + "/"
    file_name = "temp.csv"
    File.open(File.join(directory, file_name), 'w+') do |f|
      f.puts "Last Updated,In Progress,Phone Number," + drive_question_schema(form)
    end
    session = GoogleDrive.saved_session("config.json")
    session.upload_from_file((directory + file_name), (form.name + " (Responses).csv"), convert: false)
  end

  def drive_question_schema(form)
    return "Question 1, Question 2A, Question 2B, Question 3"
  end

  def send_twilio(number, body)
    puts "sending"
    puts number
    puts body
    # Test creds
    #account_sid = 'AC6016613046133ebde46069a02581cc7e'
    #auth_token = '8a45795f032cb5fd0b5f0567b58951be' 
     
    #@client = Twilio::REST::Client.new account_sid, auth_token  
    #@client.account.messages.create({
    #  from: @@twilio_number,
    #  to: number,
    #  body: body
    #})
  end
end
