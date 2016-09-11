class Form < ActiveRecord::Base
  has_many :questions, :dependent => :delete_all
  validates :json, presence: true
end
