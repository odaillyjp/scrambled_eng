# == Schema Information
#
# Table name: histories
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  challenge_id   :integer          not null
#  unix_timestamp :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class History < ActiveRecord::Base
  belongs_to :user
  belongs_to :challenge

  validates :challenge_id, presence: true

  before_create :create_with_unix_timestamp

  private

  def create_with_unix_timestamp
    if unix_timestamp.nil?
      current_day_unix_time = current_time_from_proper_timezone.beginning_of_day.to_i
      write_attribute(:unix_timestamp, current_day_unix_time)
    end
  end
end
