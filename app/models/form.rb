class Form < ActiveRecord::Base
  has_many :questions
  validates :json, presence: true
end
