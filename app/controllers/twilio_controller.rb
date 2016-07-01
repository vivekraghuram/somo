require 'twilio-ruby'
require "google/api_client"
require "google_drive"

class TwilioController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  @@twilio_number = '+14083421089'
  @@account_sid = 'AC997d895e03da78468d7a954541370e32'
  @@auth_token = '62282bd011e55c6ec20c8b51e91764bf'

  @@survey_start = 'Welcome to Somo surveys: reply BEGIN to start, and FINISH to stop'
  @@survey_end = 'Thank you for using Somo surveys'
  @@survey_over = 'Your survey is over'

  @@abc = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  @@DEBUG = false

  def start
    form = Form.find(params[:form].to_i)
    send_twilio(("+" + params[:phone]), @@survey_start)
    # TODO Check if Exists First
    TwilioState.create(phone: ("+" + params[:phone]), state: 0, form: form, alpha_index: 0)
    drive_init(form, ("+" + params[:phone]))
    render :nothing => true
  end

  def recieve
    if params[:SmsStatus] == "received"
      response_number = params[:From]
      response_body = params[:Body].strip.upcase
      if @@DEBUG
        puts "reponse number: " + response_number.to_s + " body: " + response_body.to_s
      end
      ts = TwilioState.find_by phone: response_number
      if ts.blank? # Recieved Response without Number found
        TwilioState.create(phone: response_number, state: 0, form: Form.last, alpha_index: 0)
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
            ts.question = Question.find(ts.form.firstQuestion)
            ts.save
            send_twilio(response_number, ts.form.intro)
            response_body = construct_question(ts)
            drive_init(ts.form, response_number)
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
          if answers_question(ts, response_body)
            if ts.question.questionType == "short_answer" # short answer value blank
              opt = Option.find_by(question: ts.question)
              drive_save(ts.form, ts.question, response_body, response_number)
            else
              opt = ts.question.options[alpha_cycle(ts.alpha_index).index(response_body)]
              drive_save(ts.form, ts.question, opt.value, response_number)
              ts.alpha_index = (ts.alpha_index + ts.question.options.length) % @@abc.size
            end
            if opt.nextQuestion.nil? # at END of survey
              ts.state = 2
              response_body = @@survey_end
              if @@DEBUG
                puts "Survey Complete"
              end
            else
              ts.question = Question.find(opt.nextQuestion)
              response_body = construct_question(ts)
              if @@DEBUG
                puts "Survey Continues with question: " + ts.question.id.to_s
              end
            end
            ts.save
          else # Doesn't answer question RESEND
            response_body = construct_question(ts)
            if @@DEBUG
              puts "Invalid response resending question: " + ts.question.id.to_s
            end
          end
        else # state not in enum
          puts "ERROR: unknown state (someone is monkeying around in the db)"
        end
      end
      send_twilio(response_number, response_body)
    else # Twilio api returned not recieved response
      puts "ERROR: was not recieved - invalid twilio response"
    end
    render :nothing => true
  end

  def construct_question(ts) # returns body of message
    if @@DEBUG
      puts "contructing question: " + ts.question.to_s
    end
    abc = alpha_cycle(ts.alpha_index)
    options = ts.question.options
    response = ts.question.text + "\n"
    if ts.question.questionType != "short_answer"
      # TODO More options than ABC's
      options.each do |option|
        response += "\n" + abc[0].upcase + ": " + option.value
        abc[0] = ""
      end
      if ts.question.questionType == "multiple_choice" || ts.question.questionType == "conditional"
      response += "\n\nRespond with a single letter ex: B"
      elsif ts.question.questionType == "checkbox"
        response += "\n\nRespond with one or more letters ex: AC"
      else
        puts "ERROR: unknown question type"
      end
    else
      response += "\n\nRespond with a short answer (max 120 characters)"
    end
    if @@DEBUG
      puts "question: " + response
    end
    return response
  end

  def answers_question(ts, value)
    if @@DEBUG
      puts "answering question: " + ts.question.to_s + " with value: " + value.to_s
    end
    abc = alpha_cycle(ts.alpha_index)
    options = ts.question.options
    if ts.question.questionType == "short_answer"
      return true
    elsif ts.question.questionType == "checkbox"
      value.strip.upcase.gsub(/[^A-Z]/, "").each do |choice|
        index = abc.index(choice)
        if index.nil? or (index + 1) > options.length
          return false
        end
        return true
      end
    elsif ts.question.questionType == "multiple_choice" || ts.question.questionType == "conditional"
      value = value.upcase.gsub(/[^A-Z]/, "")
      if value.length > 1
        return false
      end
      index = abc.index(value)
      if index.nil? or (index + 1) > options.length
        return false
      end
      return true
    end
    return false
  end

  def alpha_cycle(index)
    @@abc[index..@@abc.size] + @@abc[0..index-1]
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
    worksheet[row, 4] = "very well" # hard code question.drive_column
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
    return "Question 1,Question 2,Question 3,Question 4, Question 5" # hard code schema
    #sorted_questions = form.questions.sort
    #sorted_questions.each_with_index do |q, i|
    #  q.update_attribute drive_column: i + 3
    #end
    #return sorted_questions.map{|q| q.qname}.join(",")
  end

  def send_twilio(number, body)
    if @@DEBUG
      puts "sending"
      puts number
      puts body
    end

    @client = Twilio::REST::Client.new @@account_sid, @@auth_token
    @client.account.messages.create({
      from: @@twilio_number,
      to: number,
      body: body
    })
  end
end
