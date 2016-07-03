class PagesController < ApplicationController
  def home
    @forms = Form.all
  end
end
