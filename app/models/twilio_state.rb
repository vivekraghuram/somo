class TwilioState < ActiveRecord::Base
  belongs_to :form
  belongs_to :question
  enum state: [:welcome, :questioning, :stopped]
end
