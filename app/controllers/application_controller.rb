class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  def send_twilio

  end

  def render_json_message(status, options = {})
    render json: {
      message: options[:message],
      to: options[:to],
      errors: options[:errors],
      data: options[:data]
    }, status: status
  end
end
