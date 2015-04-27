class Answer
  class Mistake
    attr_accessor :cloze_text, :message, :position

    def initialize
      @cloze_text = nil
      @message = nil
      @position = nil
    end

    def spelling_mistake?
      position.present?
    end
  end
end
