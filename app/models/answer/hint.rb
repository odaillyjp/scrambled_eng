class Answer
  class Hint
    attr_reader :next_word, :answer_text, :cloze_text

    include WordExtractable

    def initialize(answer)
      @answer = answer
      @next_word = fetch_next_word
      @answer_text = fetch_answer_text_with_next_word
      @cloze_text = fetch_cloze_text_with_next_word
    end

    private

    def fetch_next_word
      @answer.correct_words[next_word_position]
    end

    def fetch_answer_text_with_next_word
      if @answer.mistake.spelling_mistake?
        # 文の途中に誤りがある場合は、誤りがあった単語の位置に正しい単語を入れる
        replaced_words = @answer.answer_words.clone
        replaced_words[@answer.mistake.position] = @next_word
        @answer.answer_text.gsub(WORD_REGEXP, '%s') % replaced_words
      else
        # 文の途中に誤りがない場合は、次の正しい単語を加える
        [@answer.answer_text, @next_word].reject(&:blank?).join(' ')
      end
    end

    def fetch_cloze_text_with_next_word
      replaced_words = scan_word(@answer.mistake.cloze_text)
      replaced_words[next_word_position] = @next_word
      @answer.correct_text.gsub(WORD_REGEXP, '%s') % replaced_words
    end

    def next_word_position
      @answer.mistake.spelling_mistake? ? @answer.mistake.position : @answer.answer_words.size
    end
  end
end
