class AnswerChecker::Text
  attr_reader :correct_text, :correct_words, :answer_text, :answer_words, :checked, :mistake, :hint
  alias_method :checked?, :checked

  include ActiveSupport::Callbacks
  include WordExtractable

  define_callbacks :after_checking, :before_check
  set_callback :after_checking, :after, -> { @checked = true }
  set_callback :before_check, :before, :check!, unless: :checked?

  def initialize(base, correct_text, answer_text)
    @base = base
    @correct_text = correct_text.strip
    @correct_words = scan_word(correct_text)
    @answer_text = answer_text.strip
    @answer_words = scan_word(answer_text)
    @checked = false
    @mistake = nil
  end

  def correct?
    # 注意: 大文字・小文字の区別はしない
    # 注意: 単語の綴りが合っていれば正解とする
    @correct ||= (scan_word(@correct_text.downcase) == scan_word(@answer_text.downcase))
  end

  def check!
    run_callbacks :after_checking do
      if correct?
        true
      else
        if @correct_words.size > 1
          detect_mistake_of_text
        else
          detect_mistake_of_word
        end

        false
      end
    end
  end

  def fetch_cloze_text!
    run_callbacks :before_check do
      correct? ? @correct_text : @mistake.cloze_text
    end
  end

  def collect_hint!
    return nil if correct?
    run_callbacks(:before_check) { AnswerChecker::Models::Hint.new(self) }
  end

  private

  def detect_mistake_of_text
    @mistake = AnswerChecker::Models::Mistake.new
    ziped_words = @correct_words.zip(@answer_words)

    result_words = ziped_words.map.with_index do |(correct_word, answer_word), idx|
      answer_word = '' if answer_word.blank?
      answer = AnswerChecker::Text.new(@base, correct_word, answer_word)

      next correct_word if answer.check!

      if @mistake.message.nil? && answer.mistake.message
        @mistake.message = answer.mistake.message
        @mistake.position = idx
      end

      answer.mistake.cloze_text
    end

    @mistake.message ||= fetch_mistake_message_of_text
    @mistake.cloze_text = @correct_text.gsub(WORD_REGEXP, '%s') % result_words
  end

  def detect_mistake_of_word
    @mistake = AnswerChecker::Models::Mistake.new

    # 解答の単語が空文字の場合は、全ての文字をブランク文字に置換した単語を返す
    if @answer_text.blank?
      @mistake.cloze_text = @correct_text.gsub(/./, CLOZE_MARK)
      return
    end

    @mistake.message = fetch_mistake_message_of_word
    @mistake.cloze_text = replace_incorrect_char_to_cloze_mark
  end

  # 正しい英文と解答を比べて、誤り原因メッセージを取得する
  def fetch_mistake_message_of_text
    mistake_key = case @correct_words.size <=> @answer_words.size
                  when -1 then :too_many
                  when 1  then :missing_words
                  when 0  then return nil
                  end

    fetch_mistake_message(mistake_key)
  end

  # 正しい単語と解答の単語を比べて、誤り原因メッセージを取得する
  def fetch_mistake_message_of_word
    # 正しい単語と解答の単語のどちらか短い方に文字数を合わせて、等値を判定する
    mistake_key = if @correct_text[0...@answer_text.size] == @answer_text[0...@correct_text.size]
                    # 解答の単語に誤りがない場合
                    case @correct_text.size <=> @answer_text.size
                    when -1 then :too_long
                    when 1  then :too_short
                    when 0  then return nil
                    end
                  else
                    # 解答の単語に誤りがある場合
                    :spelling_mistake
                  end

    fetch_mistake_message(mistake_key)
  end

  def fetch_mistake_message(mistake_key)
    key = :"#{@base.class.i18n_scope}.mistakes.models.#{@base.model_name.i18n_key}.#{mistake_key}"
    I18n.translate(key)
  end

  # 間違っている文字だけをブランク文字に置換する
  def replace_incorrect_char_to_cloze_mark
    ziped_chars = @correct_text.chars.zip(@answer_text.chars)
    replaced_chars = ziped_chars.map do |(correct_char, answer_char)|
      # 注意: 大文字・小文字の区別はしない
      correct_char.downcase == answer_char.try(:downcase) ? correct_char : CLOZE_MARK
    end

    replaced_chars.join
  end
end
