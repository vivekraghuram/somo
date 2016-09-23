require "google/api_client"
require "google_drive"

module GoogleDriveStorage
  extend ActiveSupport::Concern

  def drive_init(form)
    session = GoogleDrive.saved_session("config.json")
    unless spreadsheet = session.spreadsheet_by_title(drive_file_name(form))
      directory = Rails.root.join('tmp').to_s + "/"
      file_name = drive_file_name(form)
      File.open(File.join(directory, file_name), 'w+') do |f|
        f.puts "Last Updated,In Progress,Phone Number," + drive_question_schema(form)
      end
      session = GoogleDrive.saved_session("config.json")
      session.upload_from_file((directory + file_name), file_name)
    end
    spreadsheet || session.spreadsheet_by_title(drive_file_name(form))
  end

  def drive_save(form, question, value, phone_number)
    worksheet = drive_init(form).worksheets[0]

    # Find Row
    row = 0
    (2..worksheet.num_rows).each do |r|
      if worksheet[r, 3] == phone_number.gsub(/[^0-9]/, "")
        row = r
        break
      end
    end

    if row == 0
      r = drive_create_row(form, phone_number)
    end

    # Find Column
    col = 0
    (2..worksheet.num_cols).each do |c|
      if worksheet[1, c] == question.qname
        col = c
        break
      end
    end
    if col == 0
      puts "ERROR: could not find drive column for question id: " + question.id.to_s + " value: " + value + " phone: " + phone_number
    else
      worksheet[row, 1] = Time.now
      worksheet[row, 2] = true
      worksheet[row, col] = value
      worksheet.save
    end
  end

  def drive_create_row(form, phone_number)
    worksheet = drive_init(form).worksheets[0]
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
    row
  end

  def drive_file_name(form)
    form.name + ", id:#{form.id} (Responses).csv"
  end

  def drive_question_schema(form)
    form.questions.map{|q| q.qname}.join(",")
  end
end
