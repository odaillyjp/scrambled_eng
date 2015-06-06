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
