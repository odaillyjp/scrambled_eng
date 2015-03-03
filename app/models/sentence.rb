class Sentence < ActiveRecord::Base
  belongs_to :course
  validates :en_text, presence: true
  validates :ja_text, presence: true
end
