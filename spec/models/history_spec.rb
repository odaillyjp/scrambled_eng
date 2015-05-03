# == Schema Information
#
# Table name: histories
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  challenge_id   :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  unix_timestamp :integer          not null
#

require 'rails_helper'

RSpec.describe History, type: :model do
  let(:history) { build(:history) }
  subject { history }

  it { is_expected.to validate_presence_of(:challenge_id) }
end
