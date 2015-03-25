require 'rails_helper'

RSpec.describe Challenge, type: :model do
  let(:challenge) { build(:challenge) }
  subject { challenge }

  it { is_expected.to validate_presence_of(:en_text) }
  it { is_expected.to validate_presence_of(:ja_text) }
  it { is_expected.to validate_presence_of(:sequence_number) }
  it { is_expected.to validate_uniqueness_of(:sequence_number).scoped_to(:course_id) }
  it { is_expected.to respond_to(:to_param) }

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

  describe '#teach_partial_answer' do
    context '途中まで正しく入力されている文字列を渡したとき' do
      it '次の単語を加えた文字列を返すこと' do
        expect(challenge.teach_partial_answer('She sells')).to eq 'She sells seashells'
      end
    end

    context '途中に誤りがある文字列を渡したとき' do
      it '誤りがある部分を正しい単語に置換した文字列を返すこと' do
        expect(challenge.teach_partial_answer('She sells sheshells by the')).to eq 'She sells seashells by the'
      end
    end

    context '最後まで正しく入力されている文字列を渡したとき' do
      it 'そのままの文字列を返すこと' do
        expect(challenge.teach_partial_answer(challenge.en_text)).to eq challenge.en_text
      end
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

  describe '#teach_mistake_of_word' do
    context '正解の単語に"foo"、解答に"foo"を渡したとき' do
      let(:mistake) { challenge.send(:teach_mistake_of_word, 'foo', 'foo') }

      it '"foo"という文字列を持つオブジェクトを返すこと' do
        expect(mistake.cloze_text).to eq 'foo'
      end

      it 'メッセージにNullを持つオブジェクトを返すこと' do
        expect(mistake.message).to be_nil
      end
    end

    context '正解の単語に"foo"、解答に"fxx"を渡したとき' do
      let(:mistake) { challenge.send(:teach_mistake_of_word, 'foo', 'fxx') }

      it '"f__"という文字列を持つオブジェクトを返すこと' do
        expect(mistake.cloze_text).to eq 'f__'
      end

      it '"Incorrectly spelled some word."というメッセージを持つオブジェクトを返すこと' do
        expect(mistake.message).to eq I18n.t('activerecord.mistakes.models.challenge.spelling_mistake')
      end
    end

    context '正解の単語に"FOO"、解答に"foo"を渡したとき' do
      let(:mistake) { challenge.send(:teach_mistake_of_word, 'FOO', 'foo') }

      it '"FOO"という文字列を持つオブジェクトを返すこと' do
        expect(mistake.cloze_text).to eq 'FOO'
      end

      it 'メッセージにNullを持つオブジェクトを返すこと' do
        expect(mistake.message).to be_nil
      end
    end

    context '解答が正解よりも長いとき' do
      let(:mistake) { challenge.send(:teach_mistake_of_word, 'foo', 'fooo') }

      it '正解している部分だけを当てはめた文字列を持つオブジェクトを返すこと' do
        expect(mistake.cloze_text).to eq 'foo'
      end

      it '"Word is too long."というメッセージを持つオブジェクトを返すこと' do
        message = I18n.t('activerecord.mistakes.models.challenge.too_long')
        expect(mistake.message).to eq message
      end
    end

    context '解答が正解よりも短いとき' do
      let(:mistake) { challenge.send(:teach_mistake_of_word, 'foo', 'fo') }

      it '足りない部分は誤りだと扱うこと' do
        expect(mistake.cloze_text).to eq 'fo_'
      end

      it '"Word is too short."というメッセージを持つオブジェクトを返すこと' do
        message = I18n.t('activerecord.mistakes.models.challenge.too_short')
        expect(mistake.message).to eq message
      end
    end

    context '解答が正解よりも長く、途中に誤りもあるとき' do
      let(:mistake) { challenge.send(:teach_mistake_of_word, 'foo', 'fxoo') }

      it '正解している部分だけを当てはめた文字列を持つオブジェクトを返すこと' do
        expect(mistake.cloze_text).to eq 'f_o'
      end

      it '"Incorrectly spelled some word."というメッセージを持つオブジェクトを返すこと' do
        message = I18n.t('activerecord.mistakes.models.challenge.spelling_mistake')
        expect(mistake.message).to eq message
      end
    end

    context '解答が正解よりも短く、途中に誤りもあるとき' do
      let(:mistake) { challenge.send(:teach_mistake_of_word, 'foo', 'fx') }

      it '正解している部分だけを当てはめた文字列を持つオブジェクトを返すこと' do
        expect(mistake.cloze_text).to eq 'f__'
      end

      it '"Incorrectly spelled some word."というメッセージを持つオブジェクトを返すこと' do
        message = I18n.t('activerecord.mistakes.models.challenge.spelling_mistake')
        expect(mistake.message).to eq message
      end
    end
  end

  describe '#mistake_message_of_word' do
    context '正解の単語に"foo"、解答に"foo"を渡したとき' do
      subject { challenge.send(:mistake_message_of_word, 'foo', 'foo') }

      it { is_expected.to be_nil }
    end

    context '正解の単語に"foo"、解答に"fxx"を渡したとき' do
      subject { challenge.send(:mistake_message_of_word, 'foo', 'fxx') }

      it { is_expected.to eq I18n.t('activerecord.mistakes.models.challenge.spelling_mistake') }
    end

    context '解答が正解よりも長いとき' do
      subject { challenge.send(:mistake_message_of_word, 'foo', 'fooo') }

      it { is_expected.to eq I18n.t('activerecord.mistakes.models.challenge.too_long') }
    end

    context '解答が正解よりも短いとき' do
      subject { challenge.send(:mistake_message_of_word, 'foo', 'fo') }

      it { is_expected.to eq I18n.t('activerecord.mistakes.models.challenge.too_short') }
    end
  end

  describe '#replace_incorrect_char_to_cloze_mark' do
    context '正解の単語に"foo"、解答に"foo"を渡したとき' do
      subject { challenge.send(:replace_incorrect_char_to_cloze_mark, 'foo', 'foo') }

      it { is_expected.to eq 'foo' }
    end

    context '正解の単語に"foo"、解答に"fxx"を渡したとき' do
      subject { challenge.send(:replace_incorrect_char_to_cloze_mark, 'foo', 'fxx') }

      it { is_expected.to eq 'f__' }
    end

    context '正解の単語に"FOO"、解答に"foo"を渡したとき' do
      subject { challenge.send(:replace_incorrect_char_to_cloze_mark, 'FOO', 'foo') }

      it { is_expected.to eq 'FOO' }
    end
  end
end
