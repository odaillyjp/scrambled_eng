require 'rails_helper'

RSpec.describe Sentence, type: :model do
  let(:text_group) { build(:sentence) }
  subject { text_group }

  it { is_expected.to validate_presence_of(:en_text) }
  it { is_expected.to validate_presence_of(:ja_text) }
end
