class Challenge < ActiveRecord::Base
  belongs_to :course
  validates :en_text, presence: true
  validates :ja_text, presence: true
  validates :sequence_number, presence: true, uniqueness: { scope: :course_id }

  DELIMITER = '\s\r\n,.:;"()!?'
  HIDDEN_SYMBOL = '_'

  include OrderQuery
  order_query :order_course, [:sequence_number, :asc]

  default_scope -> { order(:course_id, :sequence_number) }

  def hidden_text
    en_text.gsub(/[^#{DELIMITER}]/, HIDDEN_SYMBOL)
  end

  def correct?(text)
    # 注意: 大文字・小文字の区別はしない
    # 注意: 単語の綴りが合っていれば正解とする
    correct_words = split_word(en_text.downcase.strip)
    answer_words = split_word(text.downcase.strip)

    correct_words == answer_words
  end

  # 誤っている文字だけを隠し文字に変換した文章を返す
  #
  # 例:
  #   正解の文章   => 'She sells seashells by the sheshore.'
  #   回答者の答え => 'She salls seashalls on the sxxxxxxx.'
  #   返り値       => 'She s_lls seash_lls __ the s_______.'
  #
  def teach_mistake(answer_text)
    # 注意: 単語の綴りが合っていれば正解とする
    correct_words = split_word(en_text.strip)
    answer_words = split_word(answer_text.strip)

    # 回答者の答えのが単語数が多い場合、全て誤りだと扱う
    return hidden_text if correct_words.size < answer_words.size

    result_words = correct_words.zip(answer_words).map do |(correct_word, answer_word)|
      answer_word ||= ''
      teach_mistake_of_word(correct_word, answer_word)
    end

    en_text.gsub(/[^#{DELIMITER}]+/, '%s') % result_words
  end

  def to_param
    sequence_number
  end

  private

  def split_word(text)
    text.split(/[#{DELIMITER}]+/)
  end

  # 誤っている文字だけを隠し文字に変換した単語を返す
  #
  # 例:
  #   正解の単語(correct_word)        => 'foo'
  #   回答者の答えの単語(answer_word) => 'fao'
  #   返り値                          => 'f_o'
  #
  def teach_mistake_of_word(correct_word, answer_word)
    # 回答者の答えのが文字数が多い場合、その単語は全て誤りだと扱う
    return correct_word.gsub(/./, HIDDEN_SYMBOL) if correct_word.size < answer_word.size

    correct_word.chars
      .zip(answer_word.chars)
      .map { |(correct_char, answer_char)|
        # 注意: 大文字・小文字の区別はしない
        correct_char.downcase == answer_char.try(:downcase) ? correct_char : HIDDEN_SYMBOL
      }.join
  end
end
