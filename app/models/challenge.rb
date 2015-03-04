class Challenge < ActiveRecord::Base
  belongs_to :course
  validates :en_text, presence: true
  validates :ja_text, presence: true

  DELIMITER = '\s\r\n,.:;"()!?'

  def hide_en_text(hidden_symbol = '_')
    en_text.gsub(/[^#{DELIMITER}]/, hidden_symbol)
  end
end
