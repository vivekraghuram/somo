class Question < ActiveRecord::Base
  has_many :options
  belongs_to :form
end
