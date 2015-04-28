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
  has_many :challenges, dependent: :destroy
  belongs_to :user

  validates :name, presence: true, length: { maximum: 40 }
  validates :description, length: { maximum: 120 }
  validates :level, presence: true
  validates :user_id, presence: true
  validates :state, presence: true
  validates :updatable, inclusion: { in: [true, false] }

  enum state: %i(overtness members_only secret)

  scope :only_authorized, lambda { |current_user|
    where('user_id = ? OR state = ?', current_user, Course.states[:overtness])
  }
end
