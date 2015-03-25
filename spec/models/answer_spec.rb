require 'rails_helper'

RSpec.describe Answer, type: :model do
  let(:challenge) { build(:challenge) }

  context '正解と解答が完全一致しているとき' do
    let(:answer) { challenge.build_answer(challenge.en_text) }

    describe '#correct?' do
      it { expect(answer.correct?).to be_truthy }
    end

    describe '#detect_mistake_of_text' do
      before { answer.send(:detect_mistake_of_text) }

      it '正解の文字列を持つオブジェクトを返すこと' do
        expect(answer.mistake.cloze_text).to eq challenge.en_text
      end

      it 'メッサージにNullを持つオブジェクトを返すこと' do
        expect(answer.mistake.message).to be_nil
      end

      it '誤り位置情報にNullを持つオブジェクトを返すこと' do
        expect(answer.mistake.position).to be_nil
      end
    end
  end

  context '正解と解答が完全一致していないとき' do
    let(:answer) { challenge.build_answer('She salls seashalls on the sxxxxxxx.') }

    describe '#correct?' do
      it { expect(answer.correct?).to be_falsy }
    end

    describe '#detect_mistake_of_text' do
      before { answer.send(:detect_mistake_of_text) }

      it '誤っている文字をブランク文字に置換した文字列を持つオブジェクトを返すこと' do
        expect(answer.mistake.cloze_text).to eq 'She s_lls seash_lls __ the s_______.'
      end

      it '"Incorrectly spelled some word."というメッセージを持つオブジェクトを返すこと' do
        message = I18n.t('activerecord.mistakes.models.challenge.spelling_mistake')
        expect(answer.mistake.message).to eq message
      end

      it '最初に誤りがあった単語の位置情報を持つオブジェクトを返すこと' do
        expect(answer.mistake.position).to eq 1
      end
    end
  end

  context '解答が正解の文字を全て小文字に置換した文字だったとき' do
    let(:answer) { challenge.build_answer(challenge.en_text.downcase) }

    describe '#correct?' do
      it '大文字と小文字を区別せずに正解とすること' do
        expect(answer.correct?).to be_truthy
      end
    end
  end

  context '単語の前後に余計な区切り文字が含まれているが、単語は一致しているとき' do
    let(:answer) { challenge.build_answer("\r\n        #{challenge.en_text}  \n") }

    describe '#correct?' do
      it '単語の綴りが合っていれば正解とすること' do
        expect(answer.correct?).to be_truthy
      end
    end
  end

  context '単語の前後に余計な区切り文字が含まれていて、誤りもあるとき' do
    let(:answer) { challenge.build_answer("\r\nShe   sells  xxxshalls  by  the  seashore. \n") }

    describe '#correct?' do
      it '不正解とすること' do
        expect(answer.correct?).to be_falsy
      end
    end

    describe '#detect_mistake_of_text' do
      before { answer.send(:detect_mistake_of_text) }

      it '単語の綴りだけを考慮して、誤りを教えること' do
        expect(answer.mistake.cloze_text).to eq 'She sells ___sh_lls by the seashore.'
      end
    end
  end

  context '解答にピリオドが省かれているとき' do
    let(:answer) { challenge.build_answer('She sells seashells by the seashore') }

    describe '#correct?' do
      it '単語の綴りが合っていれば正解とすること' do
        expect(answer.correct?).to be_truthy
      end
    end
  end

  context '解答にピリオドが省かれていて、誤りもあるとき' do
    let(:answer) { challenge.build_answer('The sells seashells by the seashore') }

    describe '#correct?' do
      it '不正解とすること' do
        expect(answer.correct?).to be_falsy
      end
    end

    describe '#detect_mistake_of_text' do
      before { answer.send(:detect_mistake_of_text) }

      it '単語の綴りだけを考慮して、誤りを教えること' do
        expect(answer.mistake.cloze_text).to eq '_he sells seashells by the seashore.'
      end
    end
  end

  context '解答の単語が多過ぎるとき' do
    let(:answer) { challenge.build_answer('She sells seashells by the seashore in Japan.') }

    describe '#detect_mistake_of_text' do
      before { answer.send(:detect_mistake_of_text) }

      it '正解している部分だけを当てはめた文字列を持つオブジェクトを返すこと' do
        expect(answer.mistake.cloze_text).to eq 'She sells seashells by the seashore.'
      end

      it '"Words is too many."というメッセージを持つオブジェクトを返すこと' do
        message = I18n.t('activerecord.mistakes.models.challenge.too_many')
        expect(answer.mistake.message).to eq message
      end

      it '誤り位置情報にNullを持つオブジェクトを返すこと' do
        expect(answer.mistake.position).to be_nil
      end
    end
  end

  context '解答の単語が少な過ぎるとき' do
    let(:answer) { challenge.build_answer('Shee sells seashells by the seashore.') }

    describe '#detect_mistake_of_text' do
      before { answer.send(:detect_mistake_of_text) }

      it '正解している部分だけを当てはめた文字列を持つオブジェクトを返すこと' do
        expect(answer.mistake.cloze_text).to eq 'She sells seashells by the seashore.'
      end

      it '"Word is too long."というメッセージを持つオブジェクトを返すこと' do
        message = I18n.t('activerecord.mistakes.models.challenge.too_long')
        expect(answer.mistake.message).to eq message
      end

      it '文字数が多い単語の位置情報を持つオブジェクトを返すこと' do
        expect(answer.mistake.position).to eq 0
      end
    end
  end

  context '単語数は同じだが、文字数が少ない単語がある解答を渡したとき' do
    let(:answer) { challenge.build_answer('She sells seashell by the seashore.') }

    describe '#detect_mistake_of_text' do
      before { answer.send(:detect_mistake_of_text) }

      it '正解している部分だけを当てはめた文字列を持つオブジェクトを返すこと' do
        expect(answer.mistake.cloze_text).to eq 'She sells seashell_ by the seashore.'
      end

      it '"Word is too short."というメッセージを持つオブジェクトを返すこと' do
        message = I18n.t('activerecord.mistakes.models.challenge.too_short')
        expect(answer.mistake.message).to eq message
      end

      it '文字数が少ない単語の位置情報を持つオブジェクトを返すこと' do
        expect(answer.mistake.position).to eq 2
      end
    end
  end

  context '単語数が多く、途中に誤りもある解答を渡したとき' do
    let(:answer) { challenge.build_answer('She sells seeshells by the seashore in Japan.') }

    describe '#detect_mistake_of_text' do
      before { answer.send(:detect_mistake_of_text) }

      it '正解している部分だけを当てはめた文字列を持つオブジェクトを返すこと' do
        expect(answer.mistake.cloze_text).to eq 'She sells se_shells by the seashore.'
      end

      it '"Incorrectly spelled some word."というメッセージを持つオブジェクトを返すこと' do
        message = I18n.t('activerecord.mistakes.models.challenge.spelling_mistake')
        expect(answer.mistake.message).to eq message
      end

      it '誤りがある最初の単語の位置情報を持つオブジェクトを返すこと' do
        expect(answer.mistake.position).to eq 2
      end
    end
  end

  context '単語数が少なく、途中に誤りもある解答を渡したとき' do
    let(:answer) { challenge.build_answer('She sells see') }

    describe '#detect_mistake_of_text' do
      before { answer.send(:detect_mistake_of_text) }

      it '正解している部分だけを当てはめた文字列を持つオブジェクトを返すこと' do
        expect(answer.mistake.cloze_text).to eq 'She sells se_______ __ ___ ________.'
      end

      it '"Incorrectly spelled some word."というメッセージを持つオブジェクトを返すこと' do
        message = I18n.t('activerecord.mistakes.models.challenge.spelling_mistake')
        expect(answer.mistake.message).to eq message
      end

      it '誤りがある最初の単語の位置情報を持つオブジェクトを返すこと' do
        expect(answer.mistake.position).to eq 2
      end
    end
  end
end
