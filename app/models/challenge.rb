class Challenge < ActiveRecord::Base
  belongs_to :course
  validates :en_text, presence: true
  validates :ja_text, presence: true
  validates :sequence_number, presence: true, uniqueness: { scope: :course_id }

  DELIMITER_MARK = '\s\r\n,.:;"()!?'
  DECIMAL_MARK = ',.'
  WORD_REGEXP = /(?:[^#{DELIMITER_MARK}]+|(?<=\d)[#{DECIMAL_MARK}](?=\d))+/
  HIDDEN_MARK = '_'

  include OrderQuery
  order_query :order_course, [:sequence_number, :asc]

  default_scope -> { order(:course_id, :sequence_number) }

  def hidden_text
    en_text.gsub(WORD_REGEXP) { |word| HIDDEN_MARK * word.size }
  end

  def words
    scan_word(en_text.downcase.strip)
  end

  def correct?(text)
    # 注意: 大文字・小文字の区別はしない
    # 注意: 単語の綴りが合っていれば正解とする
    correct_words = scan_word(en_text.downcase.strip)
    answer_words = scan_word(text.downcase.strip)

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
    # 注意: 大文字・小文字の区別はしない
    # 注意: 単語の綴りが合っていれば正解とする
    correct_words = scan_word(en_text.strip)
    answer_words = scan_word(answer_text.strip)
    mistake = Mistake.new

    result_words = correct_words.zip(answer_words).map do |(correct_word, answer_word)|
      word_mistake = teach_mistake_of_word(correct_word, (answer_word || ''))

      # 最初の誤り原因メッセージだけを覚えておく
      mistake.message ||= word_mistake.message

      word_mistake.hidden_text
    end

    mistake.message ||= case correct_words.size <=> answer_words.size
                        when -1 then 'Words is too many.'
                        when 1  then 'Words is very few.'
                        end

    mistake.hidden_text = en_text.gsub(WORD_REGEXP, '%s') % result_words
    mistake
  end

  def to_param
    sequence_number
  end

  private

  def scan_word(text)
    text.scan(WORD_REGEXP)
  end

  # 誤っている文字だけを隠し文字に変換した単語を返す
  #
  # 例:
  #   正解の単語(correct_word)        => 'foo'
  #   回答者の答えの単語(answer_word) => 'fao'
  #   返り値                          => 'f_o'
  #
  def teach_mistake_of_word(correct_word, answer_word)
    mistake = Mistake.new

    # （大文字・小文字を区別せずに）正解の単語と一致した場合は、正解の単語を返す
    if correct_word.downcase == answer_word.try(:downcase)
      mistake.hidden_text = correct_word
      return mistake
    end

    # 回答者の答えが空文字の場合は、全ての文字を隠し文字に変換した単語を返す
    if answer_word.blank?
      mistake.hidden_text = correct_word.gsub(/./, HIDDEN_MARK)
      return mistake
    end

    # 正解の単語・回答者の答えのどちらか短い方に文字数を合わせて、等値を判定する
    mistake.message = if correct_word[0...answer_word.size] == answer_word[0...correct_word.size]
                        # 回答者の答えに誤りがない場合
                        case correct_word.size <=> answer_word.size
                        when -1 then 'Word is too long.'
                        when 1  then 'Word is too short.'
                        when 0  then nil
                        end
                      else
                        # 回答者の答えに誤りがある場合
                        'Incorrectly spelled some word.'
                      end

    # 間違っている文字だけを隠し文字に変換する
    mistake.hidden_text = correct_word.chars
      .zip(answer_word.chars)
      .map { |(correct_char, answer_char)|
        # 注意: 大文字・小文字の区別はしない
        correct_char.downcase == answer_char.try(:downcase) ? correct_char : HIDDEN_MARK
      }.join

    mistake
  end

  class Mistake
    attr_accessor :hidden_text, :message

    def initialize
      @hidden_text = nil
      @message = nil
    end
  end
end
