# == Schema Information
#
# Table name: forms
#
#  id             :integer          not null, primary key
#  name           :string
#  intro          :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  first_question :integer
#  json           :string
#

class Form < ActiveRecord::Base
  has_many :questions, :dependent => :delete_all
  validates :json, presence: true

  def prepare
    if first_question.nil?
      first_question = create_questions(Question.new, JSON.parse(json)['questions'])
      update_attributes(first_question: first_question.id)
    end
    self
  end

  private

  def create_questions(prev_question, questions)
    questions.reverse.each do |q|
      question = Question.new(form_id: id, question_type: q["questionType"], text: q["text"], qname: q["qname"])
      if question.save!
        if !q["options"].nil?
          q["options"].each do |o|
            create_option(question, prev_question, o)
          end
        else
          create_option(question, prev_question, {"value"=>""}) # placeholder option
        end
        prev_question = question
      end
    end
    prev_question
  end

  def create_option(cur_question, prev_question, option)
    o = Option.new(question: cur_question, value: option["value"])
    if option["conditional"]
      o.next_question = create_questions(prev_question, option["questions"]).id
    else
      o.next_question = prev_question.id
    end
    o.save!
  end
end
