require 'rails_helper'

RSpec.describe Challenge, type: :model do
  let(:challenge) { build(:challenge) }
  subject { challenge }

  it { is_expected.to validate_presence_of(:en_text) }
  it { is_expected.to validate_presence_of(:ja_text) }
end
