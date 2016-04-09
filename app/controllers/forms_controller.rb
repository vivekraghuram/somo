class FormsController < ApplicationController
  def create
    form = Form.new(create_params)
    if form.save
      last_qid = nil
      cur_qid = nil
      questions = params[:questions]
      if !questions.nil?
        questions.reverse.each do |q|
          question = Question.new(form: form, questionType: q[:questionType], text: q[:text], qname: q[:qname])
          if question.save
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
                    followQuestion = Question.new(form: form, questionType: f[:questionType], text: f[:text], qname: f[:qname])
                    if followQuestion.save
                      last_fid = cur_fid
                      cur_fid = followQuestion.id
                      follow_options = f[:options]
                      if !follow_options.nil?
                        follow_options.each do |fo|
                          if last_fid.nil?
                            follow_op = Option.new(question: followQuestion, value: fo[:value], nextQuestion: last_qid)
                          else
                            follow_op = Option.new(question: followQuestion, value: fo[:value], nextQuestion: last_fid)
                          end
                          if !follow_op.save
                            render_json_message(:forbidden, errors: follow_op.errors.full_messages)
                            return
                          end
                        end
                      else
                        if last_fid.nil?
                          follow_op = Option.new(question: followQuestion, value: 'a', nextQuestion: last_qid)
                        else
                          follow_op = Option.new(question: followQuestion, value: 'b', nextQuestion: last_fid)
                        end
                        if !follow_op.save
                          render_json_message(:forbidden, errors: follow_op.errors.full_messages)
                          return
                        end
                      end
                    else
                      render_json_message(:forbidden, errors: followQuestion.errors.full_messages)
                      return
                    end
                  end
                  option = Option.new(question: question, value: o[:value], nextQuestion: cur_fid)
                  if !option.save
                    render_json_message(:forbidden, errors: option.errors.full_messages)
                    return
                  end
                end
              end
            else
              option = option.new(question: question, value: " ", nextQuestion: last_qid)
              if !option.save
                render_json_message(:forbidden, errors: option.errors.full_messages)
                return
              end
            end
          else
            render_json_message(:forbidden, errors: question.errors.full_messages)
            return
          end
        end
      end
      form.update_attributes(:firstQuestion => cur_qid)
      render_json_message(:ok, message: 'Form created!')
    else
      render_json_message(:forbidden, errors: form.errors.full_messages)
    end
  end

  private

  def create_params
    params.permit(:name, :intro)
  end
end
