# == Schema Information
#
# Table name: challenges
#
#  id              :integer          not null, primary key
#  en_text         :text             not null
#  ja_text         :text             not null
#  course_id       :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  sequence_number :integer          default(1), not null
#

class Challenge < ActiveRecord::Base
  belongs_to :course
  validates :en_text, presence: true
  validates :ja_text, presence: true
  validates :sequence_number, presence: true, uniqueness: { scope: :course_id }

  DELIMITER_MARK = '\s\r\n,.:;"()!?'
  DECIMAL_MARK = ',.'
  WORD_REGEXP = /(?:[^#{DELIMITER_MARK}]+|(?<=\d)[#{DECIMAL_MARK}](?=\d))+/
  CLOZE_MARK = '_'

  include OrderQuery
  order_query :order_course, [:sequence_number, :asc]

  default_scope -> { order(:course_id, :sequence_number) }

  # 英文中の全ての文字をブランク文字に置換した文字列を返す
  def cloze_text
    en_text.gsub(WORD_REGEXP) { |word| CLOZE_MARK * word.size }
  end

  def words
    scan_word(en_text)
  end

  def correct?(answer_text)
    # 注意: 大文字・小文字の区別はしない
    # 注意: 単語の綴りが合っていれば正解とする
    scan_word(en_text.downcase) == scan_word(answer_text.downcase)
  end

  # 正しい英文(self.en_text)と解答(answer_text)を比べて
  # 誤り情報を記憶したオブジェクトを返す
  #
  # 例:
  #   challenge = Challenge.new(en_text: 'She sells seashells by the seashore.')
  #   mistake = challenge.teach_mistake('She salls seashalls on the sxxxxxxx.')
  #   puts mistake.cloze_text
  #   # => She s_lls seash_lls __ the s_______.
  #   puts mistake.message
  #   # => Incorrectly spelled some word.
  #   puts mistake.position
  #   # => 1
  #
  def teach_mistake(answer_text)
    # 注意: 大文字・小文字の区別はしない
    # 注意: 単語の綴りが合っていれば正解とする
    correct_words = scan_word(en_text)
    answer_words = scan_word(answer_text)
    ziped_words = correct_words.zip(answer_words)
    mistake = Mistake.new

    result_words = ziped_words.map.with_index do |(correct_word, answer_word), idx|
      word_mistake = teach_mistake_of_word(correct_word, (answer_word || ''))

      # 最初の誤り原因メッセージだけを覚えておく
      mistake.message ||= word_mistake.message
      # 誤りがある最初の単語の位置情報を覚えておく
      mistake.position ||= idx if word_mistake.message.present?

      word_mistake.cloze_text
    end

    mistake.message ||= mistake_message_of_text(correct_words, answer_words)
    mistake.cloze_text = en_text.gsub(WORD_REGEXP, '%s') % result_words
    mistake
  end

  # 解答(answer_text)に次の正しい単語を加えた文字列を返す
  # 入力途中に誤りがある場合は、その部分を正した文字列を返す
  #
  # 例1:
  #   challenge = Challenge.new(en_text: 'She sells seashells by the sheshore.')
  #   puts challenge.teach_partial_answer('She sells')
  #   # => 'She sells seashells'
  #
  # 例2:
  #   challenge = Challenge.new('She sells seashells by the seashore.')
  #   puts challenge.teach_partial_answer('She sells sxxshells by')
  #   # => 'She sells seashells by'
  #
  def teach_partial_answer(answer_text)
    correct_words = scan_word(en_text)
    answer_words = scan_word(answer_text)
    mistake = teach_mistake(answer_text)

    if mistake.position.present?
      # 文の途中に誤りがある場合は、誤りがあった単語の位置に正しい単語を入れる
      answer_words[mistake.position] = correct_words[mistake.position]
      answer_text.gsub(WORD_REGEXP, '%s') % answer_words
    else
      # 文の途中に誤りがない場合は、次の正しい単語を加える
      next_correct_word = correct_words[answer_words.size]
      [answer_text.strip, next_correct_word].reject(&:blank?).join(' ')
    end
  end

  def to_param
    sequence_number.to_s
  end

  private

  def scan_word(text)
    text.strip.scan(WORD_REGEXP)
  end

  # 正しい単語(correct_word)と解答の単語(answer_word)を比べて
  # 誤り情報を記憶したオブジェクトを返す
  #
  # 例:
  #   mistake = challenge.send(:teach_mistake_of_word,
  #               'seashells',
  #               'sxxshexxs')
  #   puts mistake.cloze_text
  #   # => s__she__s
  #   puts mistake.message
  #   # => Incorrectly spelled some word.
  #
  def teach_mistake_of_word(correct_word, answer_word)
    mistake = Mistake.new

    # （大文字・小文字を区別せずに）正しい単語と一致した場合は、正しい単語を返す
    if correct_word.downcase == answer_word.try(:downcase)
      mistake.cloze_text = correct_word
      return mistake
    end

    # 解答の単語が空文字の場合は、全ての文字をブランク文字に置換した単語を返す
    if answer_word.blank?
      mistake.cloze_text = correct_word.gsub(/./, CLOZE_MARK)
      return mistake
    end

    mistake.message = mistake_message_of_word(correct_word, answer_word)
    mistake.cloze_text = replace_incorrect_char_to_cloze_mark(correct_word, answer_word)
    mistake
  end

  # 正しい英文と解答を比べて、誤り原因メッセージを取得する
  def mistake_message_of_text(correct_words, answer_words)
    mistake_key = case correct_words.size <=> answer_words.size
                  when -1 then :too_many
                  when 1  then :missing_words
                  when 0  then return nil
                  end

    key = :"#{self.class.i18n_scope}.mistakes.models.#{self.model_name.i18n_key}.#{mistake_key}"
    I18n.translate(key)
  end

  # 正しい単語と解答の単語を比べて、誤り原因メッセージを取得する
  def mistake_message_of_word(correct_word, answer_word)
    # 正しい単語と解答の単語のどちらか短い方に文字数を合わせて、等値を判定する
    mistake_key = if correct_word[0...answer_word.size] == answer_word[0...correct_word.size]
                    # 解答の単語に誤りがない場合
                    case correct_word.size <=> answer_word.size
                    when -1 then :too_long
                    when 1  then :too_short
                    when 0  then return nil
                    end
                  else
                    # 解答の単語に誤りがある場合
                    :spelling_mistake
                  end

    key = :"#{self.class.i18n_scope}.mistakes.models.#{self.model_name.i18n_key}.#{mistake_key}"
    I18n.translate(key)
  end

  # 間違っている文字だけをブランク文字に置換する
  def replace_incorrect_char_to_cloze_mark(correct_word, answer_word)
    ziped_chars = correct_word.chars.zip(answer_word.chars)
    replaced_chars = ziped_chars.map do |(correct_char, answer_char)|
      # 注意: 大文字・小文字の区別はしない
      correct_char.downcase == answer_char.try(:downcase) ? correct_char : CLOZE_MARK
    end

    replaced_chars.join
  end

  # 誤り情報を扱うオブジェクト
  class Mistake
    attr_accessor :cloze_text, :message, :position

    def initialize
      @cloze_text = nil
      @message = nil
      @position = nil
    end
  end
end
