class TwilioState < ActiveRecord::Base
  belongs_to :form
  belongs_to :question
end
