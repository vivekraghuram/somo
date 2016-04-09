class Option < ActiveRecord::Base
  belongs_to :question
  validates :value, :nextQuestion, presence: true
end
