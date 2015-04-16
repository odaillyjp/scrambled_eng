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

require 'rails_helper'

RSpec.describe Course, type: :model do
  let(:course) { build(:course) }
  subject { course }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_most(40) }
  it { is_expected.to validate_length_of(:description).is_at_most(120) }
  it { is_expected.to validate_presence_of(:level) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:state) }
  it { is_expected.to validate_presence_of(:updatable) }
end
