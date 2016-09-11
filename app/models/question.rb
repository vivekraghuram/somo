class Question < ActiveRecord::Base
  has_many :options, :dependent => :delete_all
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
    response
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

  # Updates ts to next question
  def get_answer(response_text, ts)
    opt = Option.new
    if questionType == "short_answer"
      opt = options.first
      opt.value = response_text
    else
      if questionType == "checkbox"
        # TODO
        opt = options.first
        opt.value = response_text
      elsif questionType == "multiple_choice" || questionType == "conditional"
        # TODO full reponse handling
        puts "response_text: " + response_text
        opt = options()[alpha_cycle(ts.alpha_index).index(response_text)]
      end
      ts.alpha_index = (ts.alpha_index + options.length) % ABC.size
    end
    if !opt.nil? and opt.nextQuestion.nil?
      ts.question = nil
    else
      ts.question = Question.find(opt.nextQuestion)
    end
    ts.save
    return opt.value
  end

  def alpha_cycle(index)
   ABC[index..ABC.size] + ABC[0..index-1]
  end
end
