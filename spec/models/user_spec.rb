require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }
  subject { user }

  it { is_expected.to validate_presence_of(:uid) }
  it { is_expected.to validate_presence_of(:provider) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:uid).scoped_to(:provider) }
end
