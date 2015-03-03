require 'rails_helper'

RSpec.describe Sentence, type: :model do
  let(:sentence) { build(:sentence) }
  subject { sentence }

  it { is_expected.to validate_presence_of(:en_text) }
  it { is_expected.to validate_presence_of(:ja_text) }
end
