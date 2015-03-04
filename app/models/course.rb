class Course < ActiveRecord::Base
  has_many :challenges
  validates :name, presence: true
end
