require 'rails_helper'

RSpec.describe Challenge, type: :model do
  let(:challenge) { build(:challenge) }
  subject { challenge }

  it { is_expected.to validate_presence_of(:en_text) }
  it { is_expected.to validate_length_of(:en_text).is_at_most(1000) }
  it { is_expected.to validate_presence_of(:ja_text) }
  it { is_expected.to validate_length_of(:ja_text).is_at_most(1000) }
  it { is_expected.to validate_presence_of(:course_id) }
  it { is_expected.to validate_presence_of(:sequence_number) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_uniqueness_of(:sequence_number).scoped_to(:course_id) }
  it { is_expected.to respond_to(:to_key) }
  it { is_expected.to respond_to(:to_param) }
  it { is_expected.to respond_to(:course_name) }
  it { is_expected.to respond_to(:course_description) }
  it { is_expected.to respond_to(:course_level) }

  describe '#cloze_text' do
    it '区切り文字以外の全ての文字をブランク文字に置換した文字列を返すこと' do
      expect(challenge.cloze_text).to eq '___ _____ _________ __ ___ ________.'
    end
  end

  describe '#words' do
    it '文中に使わている単語を返すこと' do
      expect(challenge.words).to eq %w(She sells seashells by the seashore)
    end
  end

  # private methods

  describe '#scan_word' do
    context '"foo bar,buzz:hoge\r\npiyo"を渡したとき' do
      it '["foo", "bar", "buzz", "hoge", "piyo"] を返すこと' do
        expect_ary = %w(foo bar buzz hoge piyo)
        expect(challenge.send(:scan_word, "foo bar,buzz:hoge\r\npiyo")).to eq expect_ary
      end
    end

    context '"In Tokyo, More than 1,000 people have been lived."を渡したとき' do
      it '["In", "Tokyo", "More", "than", "1,000", "people", "have", "been", "lived"]を返すこと' do
        text = 'In Tokyo, More than 1,000 people have been lived.'
        expect_ary = %w(In Tokyo More than 1,000 people have been lived)
        expect(challenge.send(:scan_word, text)).to eq expect_ary
      end
    end

    context '"   In Tokyo, More than 1,000 people have been lived.   "を渡したとき' do
      it '["In", "Tokyo", "More", "than", "1,000", "people", "have", "been", "lived"]を返すこと' do
        text = '   In Tokyo, More than 1,000 people have been lived.   '
        expect_ary = %w(In Tokyo More than 1,000 people have been lived)
        expect(challenge.send(:scan_word, text)).to eq expect_ary
      end
    end
  end
end
