class FormsController < ApplicationController
  def new
  end

  def create
    form = Form.new(name: params["name"], intro: params["intro"], json: params.to_json)
    if form.save
      render_json_message(:ok, message: 'Form created!', data: { save_path: form_update_path(form.id), edit_path: edit_form_path(form.id) })
    else
      render_json_message(:forbidden, errors: form.errors.full_messages)
    end
  end

  def edit
    # return json
    @form = Form.find(params[:id])
  end

  def update
    # save json
    form = Form.find(params[:form_id])
    if form.update(name: params["name"], intro: params["intro"], json: params.to_json)
      render_json_message(:ok, message: "Form saved!")
    else
      render_json_message(:forbidden, errors: form.errors.full_messages)
    end
  end

  def destroy
    form = Form.find(params[:id])
    if form.destroy
      redirect_to(root_path)
    else
      render_json_message(:forbidden, errors: form.errors.full_messages)
    end
  end
end
