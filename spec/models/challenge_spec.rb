require 'rails_helper'

RSpec.describe Challenge, type: :model do
  let(:challenge) { build(:challenge) }
  subject { challenge }

  it { is_expected.to validate_presence_of(:en_text) }
  it { is_expected.to validate_presence_of(:ja_text) }

  describe '#hidden_text' do
    it '区切り文字以外の全ての文字を隠し文字に変換した文字列を返すこと' do
      expect(challenge.hidden_text).to eq '___ _____ _________ __ ___ ________.'
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
      it '正解の文字列を返すこと' do
        expect(challenge.teach_mistake(challenge.en_text)).to eq challenge.en_text
      end
    end

    context 'ミススペルがある文字列を渡したとき' do
      it 'ミススペルを隠し文字に変換した文字列を返すこと' do
        answer_text = 'She salls seashalls on the sxxxxxxx.'
        expect_text = 'She s_lls seash_lls __ the s_______.'
        expect(challenge.teach_mistake(answer_text)).to eq expect_text
      end
    end

    context '答えの文字を全て小文字に変換した文字列を渡したとき' do
      it '大文字と小文字を区別せずに、誤りを教えること' do
        answer_text = 'she yelll xxxshalls by the seashore.'
        expect_text = 'She _ell_ ___sh_lls by the seashore.'
        expect(challenge.teach_mistake(answer_text)).to eq expect_text
      end
    end

    context '答えの前後に余計な区切り文字が含まていたとき' do
      it '単語の綴りだけを考慮して、誤りを教えること' do
        answer_text = "\r\nShe   sells  xxxshalls  by  the  seashore. \n"
        expect_text = 'She sells ___sh_lls by the seashore.'
        expect(challenge.teach_mistake(answer_text)).to eq expect_text
      end
    end

    context 'ピリオドを省いた答えを渡したとき' do
      it '単語の綴りだけを考慮して、誤りを教えること' do
        answer_text = 'The sells seashells by the seashore'
        expect_text = '_he sells seashells by the seashore.'
        expect(challenge.teach_mistake(answer_text)).to eq expect_text
      end
    end

    context '単語数が多い文字列を渡したとき' do
      it '全て誤りだと扱うこと' do
        answer_text = 'She sells a seashell by the seashore.'
        expect(challenge.teach_mistake(answer_text)).to eq challenge.hidden_text
      end
    end
  end

  # private methods

  describe '#split_word' do
    context '"foo bar,buzz:hoge\r\npiyo"を渡したとき' do
      it '["foo", "bar", "buzz", "hoge", "piyo"] を返すこと' do
        expect_ary = %w(foo bar buzz hoge piyo)
        expect(challenge.send(:split_word, "foo bar,buzz:hoge\r\npiyo")).to eq expect_ary
      end
    end
  end

  describe '#teach_mistake_of_word' do
    context '正解の単語に"foo"、回答者の答えに"foo"を渡したとき' do
      it '"foo"を返すこと' do
        expect(challenge.send(:teach_mistake_of_word, 'foo', 'foo')).to eq 'foo'
      end
    end

    context '正解の単語に"foo"、回答者の答えに"fxx"を渡したとき' do
      it '"f__"を返すこと' do
        expect(challenge.send(:teach_mistake_of_word, 'foo', 'fxx')).to eq 'f__'
      end
    end

    context '正解の単語に"FOO"、回答者の答えに"foo"を渡したとき' do
      it '"FOO"を返すこと' do
        expect(challenge.send(:teach_mistake_of_word, 'FOO', 'foo')).to eq 'FOO'
      end
    end

    context '回答者の答えが正解よりのも長いとき' do
      it '全て誤りだと扱うこと' do
        expect(challenge.send(:teach_mistake_of_word, 'foo', 'fooo')).to eq '___'
      end
    end

    context '回答者の答えが正解よりのも短いとき' do
      it '足りない部分は誤りだと扱うこと' do
        expect(challenge.send(:teach_mistake_of_word, 'foo', 'fo')).to eq 'fo_'
      end
    end
  end
end
