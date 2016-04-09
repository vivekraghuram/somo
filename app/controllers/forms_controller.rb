class FormsController < ApplicationController
  def create
    if !params[:name].nil?
      form = Form.create(create_params)
    end
    if form && form.save
      questions = params[:questions]
      if !questions.nil?
        questionNum = 1
        questions.each do |q|
          question = Question.create(form: form, questionType: q[:questionType], text: q[:text], name: questionNum.to_s)
          if question && question.save
            options = q[:options]
            if !options.nil?
              letters = 'abcdefghijklmnopqrstuvwxyz'
              optionNum = 0
              options.each do |o|
                nextQ = o[:nextQuestion]
                if !nextQ.nil?
                  nextQ = Question.create(form: form, questionType: nextQ[:questionType], text: nextQ[:text],
                                          name: questionNum.to_s + letters[optionNum])
                    optionNum = optionNum + 1
                end
                Option.create(question: question, value: o[:value], nextQuestion: nextQ.id)
              end
            end
          else
            render_json_message(:forbidden, errors: ['Question creation failed.'])
          end
          questionNum = questionNum + 1
        end
      end
      render_json_message(:ok, message: 'Form created!')
    else
      render_json_message(:forbidden, errors: ['Form creation failed.'])
    end
  end

  private

  def create_params
    params.permit(:name, :intro)
  end
end
