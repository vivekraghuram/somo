class Form < ActiveRecord::Base
  has_many :questions
  validates :name, :intro, presence: true
end
