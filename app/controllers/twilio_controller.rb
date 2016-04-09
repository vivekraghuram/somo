require 'twilio-ruby'
require "google/api_client"
require "google_drive"

class TwilioController < ApplicationController
  skip_before_action :verify_authenticity_token

  @@twilio_number = '+14085164672'
  @@account_sid = 'ACc5f882e1e4d40eb6e854830f67a20643'
  @@auth_token = '6e6cdc5b174ee4a0ae0ef8ac7854a2d6'

  @@survey_start = 'Welcome to Somo surveys: reply BEGIN to start, and FINISH to stop'
  @@survey_end = 'Thank you for using Somo surveys'

  @@abc = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

  def start
    form = Form.find(params[:form].to_i)
    send_twilio(("+" + params[:phone]), @@survey_start)
    TwilioState.create(phone: ("+" + params[:phone]), state: 0, form: form)
    drive_init(form, ("+" + params[:phone]))
    render :nothing => true
  end

  def status
    puts params
  end

  def recieve
    if params[:SmsStatus] == "received"
      response_number = params[:From]
      response_body = params[:Body].strip.upcase
      puts "reponse " + response_number + " " + response_body
      ts = TwilioState.find_by phone: response_number
      puts ts.state
      if !ts.blank? and         
        if response_body == "FINISH" or ts.state == 2 # END
          puts "recieved end of in stopped state"
          ts.destroy
          response_body = @@survey_end
        elsif ts.state == 0 # WELCOME
          puts "in welcome state"
          if response_body == "BEGIN"
            puts "recieved begin"
            ts.state += 1
            ts.question = Question.find(ts.form.firstQuestion)
            ts.save
            send_twilio(response_number, ts.form.intro)
            response_body = construct_question(ts.question)
            #drive_init(ts.form, response_number)
          else # USER welcomed and !start
            puts "USER welcomed and not started"
            response_body = @@survey_start
          end
        elsif ts.state == 1 # QUESTIONING
          puts "in questioning state"
          if answers_question(ts.question, response_body)
            puts "correctly answers question"
            drive_save(ts.form, ts.question, response_body, response_number)
            if ts.question.questionType == "short_answer" # short answer value blank
              puts "answered short answer"
              opt = Option.find_by(question: ts.question, value: "")
            else
              puts "values should match TODO"
              opt = Option.find_by(question: ts.question, value: response_body)
            end
            nextQ = opt.nextQuestion
            if nextQ.nil? # at END of survey
              puts "no next question"
              ts.state += 1
              ts.save
              response_body = @@survey_end 
            else
              puts "there is a next question"
              ts.question = nextQ
              ts.save
              response_body = construct_question(ts.question)
            end
          else # RESEND
            puts "doesn't answer question"
            response_body = construct_question(ts.question)
          end
        else # state not in enum
          puts "error unknown state"
        end
      else # Number not found - DEFAULT last created form
        response_body = @@survey_start
        ts = TwilioState.find_or_create_by(phone: response_number)
        ts.update_attributes(state: 0, form: Form.last)
        ts.save
      end
      send_twilio(response_number, response_body)
    else # Twilio api returned not recieved response
      puts "was not recieved"
    end
    render :nothing => true
  end

  def construct_question(question) # returns body of message
    abc = @@abc.dup
    puts "question: " + question.questionType
    options = question.options
    
    response = question.text + "\n"
    if question.questionType != "short_answer"
      puts "not short answer"
      puts options
      options.each do |option|
        puts option
        response += "\n" + abc[0].upcase + option.value
        abc[0] = ""
      end
      if question.questionType == "multiple_choice" || question.questionType == "conditional"
        response += "\n\nRespond with a single letter ex: B"
      elsif question.questionType == "checkbox"
        response += "\n\nRespond with one or more letters ex: AC"
      else
        puts "unknown question type"
      end
    else
      response += "\n\nRespond with a short answer (max 120 characters)"
    end
    puts "response: " + response
    return response
  end

  def answers_question(question, value)
    abc = @@abc.dup
    options = question.options
    if question.questionType == "short_answer"
      return true
    elsif question.questionType == "checkbox"
      value.strip.upcase.gsub(/[^A-Z]/, "").each do |choice|
        index = abc.index(choice)
        puts index + ' ' + options.length
        if index.nil? or (index + 1) > options.length
          return false
        end
        return true
      end
    elsif question.questionType == "multiple_choice" || question.questionType == "conditional"
      value = value.upcase.gsub(/[^A-Z]/, "")
      puts value
      if value.length > 1
        return false
      end
      puts index + " " + options.length
      index = abc.index(value)
      if index.nil? or (index + 1) > options.length
        return false
      end
      return true
    end
    return false
  end

  def drive_save(form, question, value, phone_number)
    session = GoogleDrive.saved_session("config.json")
    worksheet = session.spreadsheet_by_title(drive_file_name(form)).worksheets[0]

    # Find Row
    row = 0
    (2..worksheet.num_rows).each do |r|
      if worksheet[r, 3] == phone_number
        row = r
        break
      end
    end
    worksheet[row, 1] = Time.now
    worksheet[row, 2] = true
    worksheet[row, question.drive_column] = value
    worksheet.save
  end

  def drive_init(form, phone_number)
    directory = Rails.root.join('tmp').to_s + "/"
    file_name = drive_file_name(form)
    File.open(File.join(directory, file_name), 'w+') do |f|
      f.puts "Last Updated,In Progress,Phone Number," + drive_question_schema(form)
      f.puts ",," + phone_number + ("," * form.questions.length)
    end
    session = GoogleDrive.saved_session("config.json")
    session.upload_from_file((directory + file_name), file_name)
  end

  def drive_file_name(form)
     return form.name + " (Responses).csv"
  end

  def drive_question_schema(form)
    sorted_questions = form.questions.sort{|q1, q2| q1.qname <=> q2.qname}
    sorted_questions.each_with_index do |q, i|
      q.update_attribute drive_column: i
    end
    return sorted_questions.map{|q| q.qname}.join(",")
  end

  def send_twilio(number, body)
    puts "sending"
    puts number
    puts body
    # Test creds
    #account_sid = 'AC6016613046133ebde46069a02581cc7e'
    #auth_token = '8a45795f032cb5fd0b5f0567b58951be'

    @client = Twilio::REST::Client.new @@account_sid, @@auth_token
    @client.account.messages.create({
      from: @@twilio_number,
      to: number,
      body: body
    })
  end
end
