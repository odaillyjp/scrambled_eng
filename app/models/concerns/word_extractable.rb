module WordExtractable
  extend ActiveSupport::Concern

  DELIMITER_MARK = '\s\r\n,.:;"()!?'
  DECIMAL_MARK = ',.'
  WORD_REGEXP = /(?:[^#{DELIMITER_MARK}]+|(?<=\d)[#{DECIMAL_MARK}](?=\d))+/
  CLOZE_MARK = '_'

  private

  def scan_word(text)
    text.strip.scan(WORD_REGEXP)
  end
end
