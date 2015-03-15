# == Schema Information
#
# Table name: courses
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Course < ActiveRecord::Base
  has_many :challenges
  validates :name, presence: true
end
