require 'rails_helper'

RSpec.describe Answer, type: :model do
  context '問題が文章のとき' do
    let(:challenge) { build(:challenge) }

    context '解答が正解と完全一致しているとき' do
      let(:answer) { challenge.build_answer(challenge.en_text) }

      describe '#correct?' do
        it { expect(answer.correct?).to be_truthy }
      end

      describe '#check!' do
        it { expect(answer.check!).to be_truthy }

        it 'MistakeがNullのままであること' do
          answer.check!
          expect(answer.mistake).to be_nil
        end
      end

      context '#check! を呼び出し済みのとき' do
        before { answer.check! }

        describe '#checked?' do
          it { expect(answer.checked?).to be_truthy }
        end
      end

      context '#check! を呼び出していないとき' do
        describe '#checked?' do
          it { expect(answer.checked?).to be_falsy }
        end
      end

      describe '#fetch_cloze_text!' do
        it '正解の文章を返すこと' do
          expect(answer.fetch_cloze_text!).to eq challenge.en_text
        end
      end

      describe '#require_hint!' do
        it { expect(answer.require_hint!).to be_nil }

        it 'MistakeがNullのままであること' do
          answer.require_hint!
          expect(answer.mistake).to be_nil
        end

        it 'HintがNullのままであること' do
          answer.require_hint!
          expect(answer.hint).to be_nil
        end
      end

      describe '#detect_mistake_of_text' do
        before { answer.send(:detect_mistake_of_text) }

        it '正解の文字列を持つオブジェクトを返すこと' do
          expect(answer.mistake.cloze_text).to eq challenge.en_text
        end

        it 'メッセージにNullを持つオブジェクトを返すこと' do
          expect(answer.mistake.message).to be_nil
        end

        it '誤り位置情報にNullを持つオブジェクトを返すこと' do
          expect(answer.mistake.position).to be_nil
        end
      end
    end

    context '解答が正解と完全一致していないとき' do
      let(:answer) { challenge.build_answer('She salls seashalls on the sxxxxxxx.') }

      describe '#correct?' do
        it { expect(answer.correct?).to be_falsy }
      end

      describe '#check!' do
        it { expect(answer.check!).to be_falsy }

        it 'mistakeに誤り情報オブジェクトが入っていること' do
          answer.check!
          expect(answer.mistake).to respond_to(:cloze_text)
          expect(answer.mistake).to respond_to(:message)
          expect(answer.mistake).to respond_to(:position)
        end
      end

      context '#check! を呼び出し済みのとき' do
        before { answer.check! }

        describe '#checked?' do
          it { expect(answer.checked?).to be_truthy }
        end
      end

      describe '#fetch_cloze_text!' do
        it '誤っている部分をブランク文字に置換した文字列を返すこと' do
          expect(answer.fetch_cloze_text!).to eq 'She s_lls seash_lls __ the s_______.'
        end
      end

      context '#check! を呼び出していないとき' do
        describe '#checked?' do
          it { expect(answer.checked?).to be_falsy }
        end
      end

      describe '#require_hint!' do
        before { answer.send(:require_hint!) }

        it 'hintが最初に誤っている単語を持っていること' do
          expect(answer.hint.next_word).to eq 'sells'
        end

        it 'hintが最初に誤っている単語を表示された解答を持っていること' do
          text = 'She sells seashalls on the sxxxxxxx.'
          expect(answer.hint.answer_text_with_next_word).to eq text
        end

        it 'hintが最初に誤っている単語を表示されたcloze_textを持っていること' do
          expect(answer.hint.cloze_text_with_next_word).to eq 'She sells seash_lls __ the s_______.'
        end

        it 'mistakeのcloze_textは何も変わらないこと' do
          expect(answer.mistake.cloze_text).to eq 'She s_lls seash_lls __ the s_______.'
        end
      end

      describe '#detect_mistake_of_text' do
        before { answer.send(:detect_mistake_of_text) }

        it 'mistakeに誤っている文字をブランク文字に置換した文字列を持つこと' do
          expect(answer.mistake.cloze_text).to eq 'She s_lls seash_lls __ the s_______.'
        end

        it 'mistakeに"Incorrectly spelled some word."というメッセージを持つこと' do
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
      let(:answer) { challenge.build_answer('She sells seashells') }

      describe '#require_hint!' do
        before { answer.require_hint! }

        it 'hintが次の単語を持っていること' do
          expect(answer.hint.next_word).to eq 'by'
        end

        it 'hintが次の単語を解答に加えた文字列を持っていること' do
          expect(answer.hint.answer_text_with_next_word).to eq 'She sells seashells by'
        end

        it 'hintが次の単語をcloze_textに加えた文字列を持っていること' do
          expect(answer.hint.cloze_text_with_next_word).to eq 'She sells seashells by ___ ________.'
        end

        it 'mistakeのcloze_textは何も変わらないこと' do
          expect(answer.mistake.cloze_text).to eq 'She sells seashells __ ___ ________.'
        end
      end

      describe '#detect_mistake_of_text' do
        before { answer.send(:detect_mistake_of_text) }

        it 'mistakeが正解している部分だけを当てはめた文字列を持っていること' do
          expect(answer.mistake.cloze_text).to eq 'She sells seashells __ ___ ________.'
        end

        it 'mistakeが"Missing some words."というメッセージを持っていること' do
          message = I18n.t('activerecord.mistakes.models.challenge.missing_words')
          expect(answer.mistake.message).to eq message
        end

        it 'mistakeが誤り位置情報にNullを持っていること' do
          expect(answer.mistake.position).to be_nil
        end
      end
    end

    context '単語数は同じだが、文字数が多い単語がある解答を渡したとき' do
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

  context '問題が単語のとき' do
    let(:challenge) { build(:challenge, en_text: 'seashell', ja_text: '貝殻') }

    context '解答が正解と完全一致しているとき' do
      let(:answer) { challenge.build_answer(challenge.en_text) }

      describe '#detect_mistake_of_word' do
        before { answer.send(:detect_mistake_of_word) }

        it '正解と同じ文字列を持つオブジェクトを返すこと' do
          expect(answer.mistake.cloze_text).to eq challenge.en_text
        end

        it 'メッセージにNullを持つオブジェクトを返すこと' do
          expect(answer.mistake.message).to be_nil
        end
      end

      describe '#fetch_mistake_message_of_word' do
        subject { answer.send(:fetch_mistake_message_of_word) }

        it { is_expected.to be_nil }
      end

      describe '#replace_incorrect_char_to_cloze_mark' do
        subject { answer.send(:replace_incorrect_char_to_cloze_mark) }

        it '正解と同じ文字列を返すこと' do
          is_expected.to eq challenge.en_text
        end
      end
    end

    context '解答が正解と完全一致していないとき' do
      let(:answer) { challenge.build_answer('seashexx') }

      describe '#detect_mistake_of_word' do
        before { answer.send(:detect_mistake_of_word) }

        it '誤っている文字をブランク文字に置換した文字列を持つオブジェクトを返すこと' do
          expect(answer.mistake.cloze_text).to eq 'seashe__'
        end

        it '"Incorrectly spelled some word."というメッセージを持つオブジェクトを返すこと' do
          message = I18n.t('activerecord.mistakes.models.challenge.spelling_mistake')
          expect(answer.mistake.message).to eq message
        end
      end

      describe '#fetch_mistake_message_of_word' do
        subject { answer.send(:fetch_mistake_message_of_word) }

        it { is_expected.to eq I18n.t('activerecord.mistakes.models.challenge.spelling_mistake') }
      end

      describe '#replace_incorrect_char_to_cloze_mark' do
        subject { answer.send(:replace_incorrect_char_to_cloze_mark) }

        it '誤っている文字をブランク文字に置換した文字列を返すこと' do
          is_expected.to eq 'seashe__'
        end
      end
    end

    context '解答が正解の文字を全て大文字に置換した文字だったとき' do
      let(:answer) { challenge.build_answer(challenge.en_text.upcase) }

      describe '#detect_mistake_of_word' do
        before { answer.send(:detect_mistake_of_word) }

        it '正解と同じ文字列を持つオブジェクトを返すこと' do
          expect(answer.mistake.cloze_text).to eq 'seashell'
        end
      end

      describe '#replace_incorrect_char_to_cloze_mark' do
        subject { answer.send(:replace_incorrect_char_to_cloze_mark) }

        it '正解と同じ文字列を返すこと' do
          is_expected.to eq 'seashell'
        end
      end
    end

    context '解答が正解よりも長いとき' do
      let(:answer) { challenge.build_answer('seashells') }

      describe '#detect_mistake_of_word' do
        before { answer.send(:detect_mistake_of_word) }

        it '正解と同じ文字列を持つオブジェクトを返すこと' do
          expect(answer.mistake.cloze_text).to eq 'seashell'
        end

        it '"Word is too long."というメッセージを持つオブジェクトを返すこと' do
          message = I18n.t('activerecord.mistakes.models.challenge.too_long')
          expect(answer.mistake.message).to eq message
        end
      end

      describe '#fetch_mistake_message_of_word' do
        subject { answer.send(:fetch_mistake_message_of_word) }

        it { is_expected.to eq I18n.t('activerecord.mistakes.models.challenge.too_long') }
      end
    end

    context '解答が正解よりも短いとき' do
      let(:answer) { challenge.build_answer('sea') }

      describe '#detect_mistake_of_word' do
        before { answer.send(:detect_mistake_of_word) }

        it '足りない部分は誤りだと扱うこと' do
          expect(answer.mistake.cloze_text).to eq 'sea_____'
        end

        it '"Word is too short."というメッセージを持つオブジェクトを返すこと' do
          message = I18n.t('activerecord.mistakes.models.challenge.too_short')
          expect(answer.mistake.message).to eq message
        end
      end

      describe '#fetch_mistake_message_of_word' do
        subject { answer.send(:fetch_mistake_message_of_word) }

        it { is_expected.to eq I18n.t('activerecord.mistakes.models.challenge.too_short') }
      end
    end

    context '解答が正解よりも長く、途中に誤りもあるとき' do
      let(:answer) { challenge.build_answer('seashexxx') }

      describe '#detect_mistake_of_word' do
        before { answer.send(:detect_mistake_of_word) }

        it '正解している部分だけを当てはめた文字列を持つオブジェクトを返すこと' do
          expect(answer.mistake.cloze_text).to eq 'seashe__'
        end

        it '"Incorrectly spelled some word."というメッセージを持つオブジェクトを返すこと' do
          message = I18n.t('activerecord.mistakes.models.challenge.spelling_mistake')
          expect(answer.mistake.message).to eq message
        end
      end
    end

    context '解答が正解よりも短く、途中に誤りもあるとき' do
      let(:answer) { challenge.build_answer('xea') }

      describe '#detect_mistake_of_word' do
        before { answer.send(:detect_mistake_of_word) }

        it '正解している部分だけを当てはめた文字列を持つオブジェクトを返すこと' do
          expect(answer.mistake.cloze_text).to eq '_ea_____'
        end

        it '"Incorrectly spelled some word."というメッセージを持つオブジェクトを返すこと' do
          message = I18n.t('activerecord.mistakes.models.challenge.spelling_mistake')
          expect(answer.mistake.message).to eq message
        end
      end
    end
  end
end
