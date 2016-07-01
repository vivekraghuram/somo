class Option < ActiveRecord::Base
  belongs_to :question
  #validates :value, presence: true
end
