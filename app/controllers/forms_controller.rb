class FormsController < ApplicationController
  def create
    form = Form.create(create_params)
    last_qid = nil
    cur_qid = nil
    questions = params[:questions]
    if !questions.nil?
      questions.reverse.each do |q|
        question = Question.create(form: form, questionType: q[:questionType], text: q[:text], qname: q[:qname])
        last_qid = cur_qid
        cur_qid = question.id
        options = q[:options]
        if !options.nil?
          options.each do |o|
            last_fid = nil
            cur_fid = nil
            followups = o[:questions]
            if !followups.nil?
              followups.reverse.each do |f|
                followQuestion = Question.create(form: form, questionType: f[:questionType], text: f[:text], qname: f[:qname])
                last_fid = cur_fid
                cur_fid = followQuestion.id
                follow_options = f[:options]
                if !follow_options.nil?
                  follow_options do |fo|
                    if last_fid.nil?
                      follow_op = Option.create(question: followQuestion, value: fo[:value], nextQuestion: last_qid)
                    else
                      follow_op = Option.create(question: followQuestion, value: fo[:value], nextQuestion: last_fid)
                  end
                else # no follow options - just create one nil one that leads to next question
                  if last_fid.nil?
                    follow_op = Option.create(question: followQuestion, value: " ", nextQuestion: last_qid)
                  else
                    follow_op = Option.create(question: followQuestion, value: " ", nextQuestion: last_fid)
                  end
                end
              end
              # after all followups, link current option to the first follow up
              option = Option.create(question: question, value: o[:value], nextQuestion: cur_fid)
            end
          end
        else # no options
          option = Option.create(question: question, value: " ", nextQuestion: last_qid)
        end
      end
    end
    form.update_attributes(:firstQuestion => cur_qid)
    render_json_message(:ok, message: 'Form created!')
  end

  private

  def create_params
    params.permit(:name, :intro)
  end
end
