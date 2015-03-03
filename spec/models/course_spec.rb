require 'rails_helper'

RSpec.describe Course, type: :model do
  let(:course) { build(:course) }
  subject { course }

  it { is_expected.to validate_presence_of(:name) }
end
