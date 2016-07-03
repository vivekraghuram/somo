class Question < ActiveRecord::Base
  has_many :options
  belongs_to :form

  validates :text, :qname, :questionType, presence: true

  ABC = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

  def construct_text(options_index)
    abc = alpha_cycle(options_index)
    response = text + "\n"
    if questionType != "short_answer"
      # TODO More options than ABC's
      options.each do |option|
        response += "\n" + abc[0].upcase + ": " + option.value
        abc[0] = ""
      end
      if questionType == "multiple_choice" || questionType == "conditional"
        response += "\n\nRespond with a single letter ex: B"
      elsif questionType == "checkbox"
        response += "\n\nRespond with one or more letters ex: AC"
      else
        puts "ERROR: unknown question type"
      end
    else
      response += "\n\nRespond with a short answer (max 120 characters)"
    end
    return response 
  end

  def valid_answer(value, options_index)
    abc = alpha_cycle(options_index)
    if questionType == "short_answer"
      return true
    elsif questionType == "checkbox"
      value.strip.upcase.gsub(/[^A-Z]/, "").each do |choice|
        index = abc.index(choice)
        if index.nil? or (index + 1) > options.length
          return false
        end
        return true
      end
    elsif questionType == "multiple_choice" || questionType == "conditional"
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
   ABC[index..ABC.size] + ABC[0..index-1]
  end
end
