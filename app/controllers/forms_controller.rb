class FormsController < ApplicationController
  def create
    puts("hello friend")
    form = Form.create(create_params)
    if form.save
      render_json_message(:ok, message: 'Form created!')
    else
      render_json_message(:forbidden, errors: ['Form creation failed.'])
    end
  end

  private

  def create_params
    puts("permitting stuff")
    params.permit(:name, :intro)
  end
end
