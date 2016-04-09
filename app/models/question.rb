class Question < ActiveRecord::Base
  has_many :questions
  belongs_to :question
end
