class FormsController < ApplicationController
  def create
    form = Form.new(create_params)
    if form && form.save
      questions = params[:questions]
      if !questions.nil?
        questionNum = 1
        # create all questions in the form
        questions.each do |q|
          question = Question.new(form: form, questionType: q[:questionType], text: q[:text], name: questionNum.to_s)
          if question && question.save
            options = q[:options]
            # create all options for each question
            if !options.nil?
              letters = 'abcdefghijklmnopqrstuvwxyz'
              optionNum = 0
              options.each do |o|
                nextQ = o[:nextQuestion]
                if !nextQ.nil?
                  # create the follow-up question if question branches
                  nextQ = Question.new(form: form, questionType: nextQ[:questionType], text: nextQ[:text],
                                          name: questionNum.to_s + letters[optionNum])
                  if nextQ && nextQ.save
                    optionNum = optionNum + 1
                  else # if follow-up question failed to create, return error
                    render_json_message(:forbidden, errors: ['Question follow-up creation failed.'])
                    return
                  end
                end
                newOption = Option.new(question: question, value: o[:value], nextQuestion: nextQ.id)
                # if option failed to create, return error
                if !newOption || !newOption.save
                  render_json_message(:forbidden, errors: ['Option creation failed.'])
                  return
                end
              end
            end
          else # if question failed to create, return error
            render_json_message(:forbidden, errors: ['Question creation failed.'])
            return
          end
          questionNum = questionNum + 1
        end
      end
      render_json_message(:ok, message: 'Form created!')
    else # if form failed to create, return error
      render_json_message(:forbidden, errors: ['Form creation failed.'])
    end
  end

  private

  def create_params
    params.permit(:name, :intro)
  end
end
