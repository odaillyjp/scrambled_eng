class TextGroup < ActiveRecord::Base
  validates :name, presence: true
end
