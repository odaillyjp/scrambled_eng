class Challenge < ActiveRecord::Base
  belongs_to :course
  belongs_to :user
  has_many :histories

  validates :en_text, presence: true, length: { maximum: 1000 }
  validates :ja_text, presence: true, length: { maximum: 1000 }
  validates :course_id, presence: true
  validates :sequence_number, presence: true, uniqueness: { scope: :course_id }
  validates :user_id, presence: true

  delegate :name, :description, :level, to: :course, prefix: :course

  include WordExtractable
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

  def build_answer(answer_text)
    AnswerChecker.new(self, en_text, answer_text)
  end

  def to_key
    [course_id.to_s, sequence_number.to_s]
  end

  def to_param
    sequence_number.to_s
  end
end
