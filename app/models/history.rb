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
end
