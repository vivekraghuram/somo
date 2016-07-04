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

  @@DEBUG = true

  def start
    form = Form.find(params[:form].to_i)
    phone = "+" + params[:phone]
    init_drive = false
    if TwilioState.find_by(form: form).blank?
      init_drive = true
    end
    if TwilioState.find_by(phone: phone).blank?
      TwilioState.create(phone: phone, state: 0, form: form, alpha_index: 0)
      # TODO Check if Exists First
      if init_drive
        drive_init(form)
      end
      drive_create_row(form, phone)
      render :nothing => true
    else
      render text: "You've already sent to this number"
    end
    ts.send_twilio(@@survey_start)
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
            ts.question = Question.find(ts.form.firstQuestion)
            ts.save
            ts.send_twilio(ts.form.intro)
            response_body = ts.question.construct_text(ts.alpha_index)
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
    else # Twilio api returned not recieved response
      puts "ERROR: was not recieved - invalid twilio response"
    end
    render :nothing => true
  end

  def drive_save(form, question, value, phone_number)
    session = GoogleDrive.saved_session("config.json")
    worksheet = session.spreadsheet_by_title(drive_file_name(form)).worksheets[0]

    # Find Row
    row = 0
    (2..worksheet.num_rows).each do |r|
      if worksheet[r, 3] == phone_number.gsub(/[^0-9]/, "")
        row = r
        break
      end
    end

    # Find Column
    col = 0
    (2..worksheet.num_cols).each do |c|
      if worksheet[1, c] == question.qname
        col = c
        break
      end
    end
    if row == 0 or col == 0
      puts "ERROR: could not find drive column for question id: " + question.id.to_s + " value: " + value + " phone: " + phone_number
    else
      worksheet[row, 1] = Time.now
      worksheet[row, 2] = true
      worksheet[row, col] = value
      worksheet.save
    end
  end

  def drive_init(form)
    directory = Rails.root.join('tmp').to_s + "/"
    file_name = drive_file_name(form)
    File.open(File.join(directory, file_name), 'w+') do |f|
      f.puts "Last Updated,In Progress,Phone Number," + drive_question_schema(form)
    end
    session = GoogleDrive.saved_session("config.json")
    session.upload_from_file((directory + file_name), file_name)
  end

  def drive_create_row(form, phone_number) 
    session = GoogleDrive.saved_session("config.json")
    worksheet = session.spreadsheet_by_title(drive_file_name(form)).worksheets[0]
    row = 2
    (2..worksheet.num_rows).each do |r|
      if worksheet[r, 3] == ""
        row = r
        break
      end
    end
    worksheet[row, 1] = Time.now
    worksheet[row, 2] = false
    worksheet[row, 3] = phone_number
    worksheet.save
  end

  def drive_file_name(form)
     return form.name + " (Responses).csv"
  end

  def drive_question_schema(form)
    return form.questions.map{|q| q.qname}.join(",")
  end
end
