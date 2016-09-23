class DesktopResponsesController < ApplicationController
  include GoogleDriveStorage

  skip_before_action :verify_authenticity_token

  def new
    @form = Form.find_by_id(params[:form_id]).prepare
  end
end
