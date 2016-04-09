class Question < ActiveRecord::Base
  has_many :options
  belongs_to :form
  validates :text, :questionType, presence: true
end
