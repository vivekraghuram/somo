class FormsController < ApplicationController
  def create
    form = Form.create(create_params)
    if form.save
      render_json_message(:ok, message: 'Form created!')
    else
      render_json_message(:forbidden, errors: ['Form creation failed.'])
    end
  else

  private

  def create_params
    params.permit(:name, :intro)
  end
end
