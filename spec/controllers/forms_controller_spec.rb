require 'rails_helper'
require 'factory_girl_rails'

describe "POST #submit" do
  it "Parses the form json and creates questions" do
    @controller = FormsController.new
    form = FactoryGirl.create(:form)
    expect{
        post :submit, form: form
      }.to change(Question,:count).by(8)
  end
end
