class FormsController < ApplicationController
  def new
  end

  def new_dev
  end

  def create
    # save json to database
    form = Form.new(create_params)
    if form.save
      render_json_message(:ok, message: 'Form created!')
    else
      render_json_message(:forbidden, errors: form.errors.full_messages)
    end
  end

  def show
    # return json
  end

  def update
    # save json
    form = Form.find(params[:id])
    if form.update(update_params)
      render_json_message(:ok, message: "Form saved!")
    else
      render_json_message(:forbidden, errors: form.errors.full_messages)
    end
  end

  def submit
    form = Form.find(params[:id])
    form_json = JSON.parse(form.json)
    last_qid = nil
    cur_qid = nil
    questions = form_json['questions']
    if !questions.nil?
      questions.reverse.each do |q|
        question = Question.new(form_id: form.id, questionType: q['questionType'], text: q['text'], qname: q['qname'])
        if question.save
          last_qid = cur_qid
          cur_qid = question.id
          options = q['options']
          if !options.nil?
            create_options(options, question, last_qid)
          else
            option = Option.new(question: question, value: "c", nextQuestion: last_qid)
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
  end

  def destroy
    form = Form.find(params[:id])
    if form.destroy
      render_json_message(:ok, message: 'Successfully deleted form!',
                                to: root_path)
    else
      render_json_message(:forbidden, errors: form.errors.full_messages)
    end
  end

  def twilio
    @f = Form.find_by_id(params[:form_id])
  end

  private

  def create_params
    params.permit(:json)
  end

  def update_params
    params.permit(:json)
  end

  def create_options(options, question, last_qid)
    options.each do |o|
      last_fid = nil
      cur_fid = nil
      followups = o['questions']
      if !followups.nil?
        cur_fid = create_questions(followups,last_fid, cur_fid, last_qid)
      end
      #create the option to link to next question
      option = Option.new(question: question, value: o['value'], nextQuestion: cur_fid)
      if !option.save
        render_json_message(:forbidden, errors: option.errors.full_messages)
        return
      end
    end
  end

  def create_questions(followups, last_fid, cur_fid, last_qid)
    followups.reverse.each do |f|
      follow_question = Question.new(form_id: form.id, questionType: f['questionType'], text: f['text'], qname: f['qname'])
      if follow_question.save
        last_fid = cur_fid
        cur_fid = follow_question.id
        follow_options = f['options']
        if !follow_options.nil?
          create_options(follow_options, follow_question, last_qid)
        else
          if last_fid.nil?
            follow_op = Option.new(question: follow_question, value: 'a', nextQuestion: last_qid)
          else
            follow_op = Option.new(question: follow_question, value: 'b', nextQuestion: last_fid)
          end
          if !follow_op.save
            render_json_message(:forbidden, errors: follow_op.errors.full_messages)
            return
          end
        end
      end
    end
  end
end
