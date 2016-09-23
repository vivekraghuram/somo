# == Schema Information
#
# Table name: options
#
#  id            :integer          not null, primary key
#  value         :string
#  question_id   :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  next_question :integer
#

class Option < ActiveRecord::Base
  belongs_to :question
  #validates :value, presence: true
end
