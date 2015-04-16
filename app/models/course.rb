# == Schema Information
#
# Table name: courses
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  description :text
#  level       :integer          default(0), not null
#  user_id     :integer          not null
#  state       :integer          default(0), not null
#  updatable   :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Course < ActiveRecord::Base
  has_many :challenges
  belongs_to :user

  validates :name, presence: true, length: { maximum: 40 }
  validates :description, length: { maximum: 120 }
  validates :level, presence: true
  validates :user_id, presence: true
  validates :state, presence: true
  validates :updatable, presence: true

  enum state: %i(secret overt)
end
