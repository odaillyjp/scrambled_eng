require 'rails_helper'

RSpec.describe Challenge, type: :model do
  let(:challenge) { build(:challenge) }
  subject { challenge }

  it { is_expected.to validate_presence_of(:en_text) }
  it { is_expected.to validate_presence_of(:ja_text) }
  it { is_expected.to validate_presence_of(:sequence_number) }
  it { is_expected.to validate_uniqueness_of(:sequence_number).scoped_to(:course_id) }
  it { is_expected.to respond_to(:to_param) }

  describe '#hidden_text' do
    it '区切り文字以外の全ての文字を隠し文字に変換した文字列を返すこと' do
      expect(challenge.hidden_text).to eq '___ _____ _________ __ ___ ________.'
    end
  end

  describe '#words' do
    it '文中に使わている単語を返すこと' do
      expect(challenge.words).to eq %w(she sells seashells by the seashore)
    end
  end

  describe '#correct?' do
    context '答えと完全一致している文字列を渡したとき' do
      it { expect(challenge.correct?(challenge.en_text)).to be_truthy }
    end

    context '答えと完全一致していない文字列を渡したとき' do
      it { expect(challenge.correct?('foo')).to be_falsy }
    end

    context '答えの文字を全て小文字に変換した文字列を渡したとき' do
      it '大文字と小文字を区別せずに正解とすること' do
        expect(challenge.correct?(challenge.en_text.downcase)).to be_truthy
      end
    end

    context '答えの前後に余計な区切り文字が含まていたとき' do
      it '単語の綴りが合っていれば正解とすること' do
        expect(challenge.correct?("\r\n   #{challenge.en_text}   \n")).to be_truthy
      end
    end

    context 'ピリオドを省いた答えを渡したとき' do
      it '単語の綴りが合っていれば正解とすること' do
        expect(challenge.correct?(challenge.en_text.delete('.'))).to be_truthy
      end
    end
  end

  describe '#teach_mistake' do
    context '正解の文字列と等しい文字列を渡したとき' do
      let(:mistake) { challenge.teach_mistake(challenge.en_text) }

      it '正解の文字列を持つオブジェクトを返すこと' do
        expect(mistake.hidden_text).to eq challenge.en_text
      end

      it 'メッサージにNullを持つオブジェクトを返すこと' do
        expect(mistake.message).to be_nil
      end

      it '誤り位置情報にNullを持つオブジェクトを返すこと' do
        expect(mistake.position).to be_nil
      end
    end

    context '誤りがある文字列を渡したとき' do
      let(:mistake) { challenge.teach_mistake('She salls seashalls on the sxxxxxxx.') }

      it '誤っている文字を隠し文字に変換した文字列を持つオブジェクトを返すこと' do
        expect(mistake.hidden_text).to eq 'She s_lls seash_lls __ the s_______.'
      end

      it '"Incorrectly spelled some word."というメッセージを持つオブジェクトを返すこと' do
        expect(mistake.message).to eq 'Incorrectly spelled some word.'
      end

      it '最初に誤りがあった単語の位置情報を持つオブジェクトを返すこと' do
        expect(mistake.position).to eq 1
      end
    end

    context '答えの文字を全て小文字に変換した文字列を渡したとき' do
      let(:mistake) { challenge.teach_mistake('she yelll xxxshalls by the seashore.') }

      it '大文字と小文字を区別せずに、誤りを教えること' do
        expect(mistake.hidden_text).to eq 'She _ell_ ___sh_lls by the seashore.'
      end
    end

    context '答えの前後に余計な区切り文字が含まていたとき' do
      let(:mistake) { challenge.teach_mistake("\r\nShe   sells  xxxshalls  by  the  seashore. \n") }

      it '単語の綴りだけを考慮して、誤りを教えること' do
        expect(mistake.hidden_text).to eq 'She sells ___sh_lls by the seashore.'
      end
    end

    context 'ピリオドを省いた答えを渡したとき' do
      let(:mistake) { challenge.teach_mistake('The sells seashells by the seashore') }

      it '単語の綴りだけを考慮して、誤りを教えること' do
        expect(mistake.hidden_text).to eq '_he sells seashells by the seashore.'
      end
    end

    context '単語数が多い文字列を渡したとき' do
      let(:mistake) { challenge.teach_mistake('She sells seashells by the seashore in Japan.') }

      it '正解している部分だけを当てはめた文字列を持つオブジェクトを返すこと' do
        expect(mistake.hidden_text).to eq 'She sells seashells by the seashore.'
      end

      it '"Words is too many."というメッセージを持つオブジェクトを返すこと' do
        expect(mistake.message).to eq 'Words is too many.'
      end

      it '誤り位置情報にNullを持つオブジェクトを返すこと' do
        expect(mistake.position).to be_nil
      end
    end

    context '単語数が少ない文字列を渡したとき' do
      let(:mistake) { challenge.teach_mistake('She sells seashells') }

      it '正解している部分だけを当てはめた文字列を持つオブジェクトを返すこと' do
        expect(mistake.hidden_text).to eq 'She sells seashells __ ___ ________.'
      end

      it '"Words is very few."というメッセージを持つオブジェクトを返すこと' do
        expect(mistake.message).to eq 'Words is very few.'
      end

      it '誤り位置情報にNullを持つオブジェクトを返すこと' do
        expect(mistake.position).to be_nil
      end
    end

    context '単語数は同じだが、文字数が多い単語がある文字列を渡したとき' do
      let(:mistake) { challenge.teach_mistake('Shee sells seashells by the seashore.') }

      it '正解している部分だけを当てはめた文字列を持つオブジェクトを返すこと' do
        expect(mistake.hidden_text).to eq 'She sells seashells by the seashore.'
      end

      it '"Word is too long."というメッセージを持つオブジェクトを返すこと' do
        expect(mistake.message).to eq 'Word is too long.'
      end

      it '文字数が多い単語の位置情報を持つオブジェクトを返すこと' do
        expect(mistake.position).to eq 0
      end
    end

    context '単語数は同じだが、文字数が少ない単語がある文字列を渡したとき' do
      let(:mistake) { challenge.teach_mistake('She sells seashell by the seashore.') }

      it '正解している部分だけを当てはめた文字列を持つオブジェクトを返すこと' do
        expect(mistake.hidden_text).to eq 'She sells seashell_ by the seashore.'
      end

      it '"Word is too short."というメッセージを持つオブジェクトを返すこと' do
        expect(mistake.message).to eq 'Word is too short.'
      end

      it '文字数が少ない単語の位置情報を持つオブジェクトを返すこと' do
        expect(mistake.position).to eq 2
      end
    end

    context '単語数が多く、途中に誤りもある文字列を渡したとき' do
      let(:mistake) { challenge.teach_mistake('She sells seeshells by the seashore in Japan.') }

      it '正解している部分だけを当てはめた文字列を持つオブジェクトを返すこと' do
        expect(mistake.hidden_text).to eq 'She sells se_shells by the seashore.'
      end

      it '"Incorrectly spelled some word."というメッセージを持つオブジェクトを返すこと' do
        expect(mistake.message).to eq 'Incorrectly spelled some word.'
      end

      it '誤りがある最初の単語の位置情報を持つオブジェクトを返すこと' do
        expect(mistake.position).to eq 2
      end
    end

    context '単語数が少なく、途中に誤りもある文字列を渡したとき' do
      let(:mistake) { challenge.teach_mistake('She sells see') }

      it '正解している部分だけを当てはめた文字列を持つオブジェクトを返すこと' do
        expect(mistake.hidden_text).to eq 'She sells se_______ __ ___ ________.'
      end

      it '"Incorrectly spelled some word."というメッセージを持つオブジェクトを返すこと' do
        expect(mistake.message).to eq 'Incorrectly spelled some word.'
      end

      it '誤りがある最初の単語の位置情報を持つオブジェクトを返すこと' do
        expect(mistake.position).to eq 2
      end
    end
  end

  describe '#teach_next_word' do
    context '途中まで正しく入力されている文字列を渡したとき' do
      it '次の単語を返すこと' do
        expect(challenge.teach_next_word('She sells')).to eq 'seashells'
      end
    end

    context '途中に誤りがある文字列を渡したとき' do
      it '誤りがある部分の正解の単語を返すこと' do
        expect(challenge.teach_next_word('She sells sheshells by the ')).to eq 'seashells'
      end
    end

    context '最後まで正しく入力されている文字列を渡したとき' do
      it { expect(challenge.teach_next_word(challenge.en_text)).to be_nil }
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
  end

  describe '#teach_mistake_of_word' do
    context '正解の単語に"foo"、回答者の答えに"foo"を渡したとき' do
      let(:mistake) { challenge.send(:teach_mistake_of_word, 'foo', 'foo') }

      it '"foo"という文字列を持つオブジェクトを返すこと' do
        expect(mistake.hidden_text).to eq 'foo'
      end

      it 'メッセージにNullを持つオブジェクトを返すこと' do
        expect(mistake.message).to be_nil
      end
    end

    context '正解の単語に"foo"、回答者の答えに"fxx"を渡したとき' do
      let(:mistake) { challenge.send(:teach_mistake_of_word, 'foo', 'fxx') }

      it '"f__"という文字列を持つオブジェクトを返すこと' do
        expect(mistake.hidden_text).to eq 'f__'
      end

      it '"Incorrectly spelled some word."というメッセージを持つオブジェクトを返すこと' do
        expect(mistake.message).to eq 'Incorrectly spelled some word.'
      end
    end

    context '正解の単語に"FOO"、回答者の答えに"foo"を渡したとき' do
      let(:mistake) { challenge.send(:teach_mistake_of_word, 'FOO', 'foo') }

      it '"FOO"という文字列を持つオブジェクトを返すこと' do
        expect(mistake.hidden_text).to eq 'FOO'
      end

      it 'メッセージにNullを持つオブジェクトを返すこと' do
        expect(mistake.message).to be_nil
      end
    end

    context '回答者の答えが正解よりも長いとき' do
      let(:mistake) { challenge.send(:teach_mistake_of_word, 'foo', 'fooo') }

      it '正解している部分だけを当てはめた文字列を持つオブジェクトを返すこと' do
        expect(mistake.hidden_text).to eq 'foo'
      end

      it '"Word is too long."というメッセージを持つオブジェクトを返すこと' do
        expect(mistake.message).to eq 'Word is too long.'
      end
    end

    context '回答者の答えが正解よりも短いとき' do
      let(:mistake) { challenge.send(:teach_mistake_of_word, 'foo', 'fo') }

      it '足りない部分は誤りだと扱うこと' do
        expect(mistake.hidden_text).to eq 'fo_'
      end

      it '"Word is too short."というメッセージを持つオブジェクトを返すこと' do
        expect(mistake.message).to eq 'Word is too short.'
      end
    end

    context '回答者の答えが正解よりも長く、途中に誤りもあるとき' do
      let(:mistake) { challenge.send(:teach_mistake_of_word, 'foo', 'fxoo') }

      it '正解している部分だけを当てはめた文字列を持つオブジェクトを返すこと' do
        expect(mistake.hidden_text).to eq 'f_o'
      end

      it '"Incorrectly spelled some word."というメッセージを持つオブジェクトを返すこと' do
        expect(mistake.message).to eq 'Incorrectly spelled some word.'
      end
    end

    context '回答者の答えが正解よりも短く、途中に誤りもあるとき' do
      let(:mistake) { challenge.send(:teach_mistake_of_word, 'foo', 'fx') }

      it '正解している部分だけを当てはめた文字列を持つオブジェクトを返すこと' do
        expect(mistake.hidden_text).to eq 'f__'
      end

      it '"Incorrectly spelled some word."というメッセージを持つオブジェクトを返すこと' do
        expect(mistake.message).to eq 'Incorrectly spelled some word.'
      end
    end
  end
end
