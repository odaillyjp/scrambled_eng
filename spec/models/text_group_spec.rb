require 'rails_helper'

RSpec.describe TextGroup, type: :model do
  let(:text_group) { build(:text_group) }
  subject { text_group }

  it { is_expected.to validate_presence_of(:name) }
end
