# == Schema Information
#
# Table name: histories
#
#  id           :integer          not null, primary key
#  user_id      :integer          not null
#  challenge_id :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryGirl.define do
  factory :history do
    user
    challenge
  end
end
