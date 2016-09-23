# == Schema Information
#
# Table name: questions
#
#  id            :integer          not null, primary key
#  question_type :string
#  text          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  form_id       :integer
#  qname         :string
#

class Question < ActiveRecord::Base
  has_many :options, :dependent => :delete_all
  belongs_to :form

  validates :text, :qname, :question_type, presence: true

  ABC = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

  def construct_text(options_index)
    abc = alpha_cycle(options_index)
    response = text + "\n"
    if question_type != "short_answer"
      # TODO More options than ABC's
      options.each do |option|
        response += "\n" + abc[0].upcase + ": " + option.value
        abc[0] = ""
      end
      if question_type == "multiple_choice" || question_type == "conditional"
        response += "\n\nRespond with a single letter ex: B"
      elsif question_type == "checkbox"
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
    if question_type == "short_answer"
      return true
    elsif question_type == "checkbox"
      value.strip.upcase.gsub(/[^A-Z]/, "").each do |choice|
        index = abc.index(choice)
        if index.nil? or (index + 1) > options.length
          return false
        end
        return true
      end
    elsif question_type == "multiple_choice" || question_type == "conditional"
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
    if question_type == "short_answer"
      opt = options.first
      opt.value = response_text
    else
      if question_type == "checkbox"
        # TODO
        opt = options.first
        opt.value = response_text
      elsif question_type == "multiple_choice" || question_type == "conditional"
        # TODO full reponse handling
        puts "response_text: " + response_text
        opt = options()[alpha_cycle(ts.alpha_index).index(response_text)]
      end
      ts.alpha_index = (ts.alpha_index + options.length) % ABC.size
    end
    if !opt.nil? and opt.next_question.nil?
      ts.question = nil
    else
      ts.question = Question.find(opt.next_question)
    end
    ts.save
    return opt.value
  end

  def alpha_cycle(index)
   ABC[index..ABC.size] + ABC[0..index-1]
  end
end
