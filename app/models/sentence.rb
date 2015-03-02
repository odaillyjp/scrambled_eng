class Sentence < ActiveRecord::Base
  belongs_to :text_group
  validates :en_text, presence: true
  validates :ja_text, presence: true
end
