class Course < ActiveRecord::Base
  validates :name, presence: true
end
