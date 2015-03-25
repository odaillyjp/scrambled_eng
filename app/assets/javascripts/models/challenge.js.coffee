app = @ScrambledEng
app.Models ?= {}

app.Models.Challenge = Backbone.Model.extend
  initialize: ->
    @listenTo @, 'change:raw_text', _.debounce =>
      @fetchHiddenText()
    , 500

  textToLead: (maxLength = 8) ->
    ja_text = @get('ja_text')
    "#{ja_text.substr(0, maxLength)}..." if ja_text

  fetchHiddenText: ->
    @_resolveRawText().done (data) =>
      if data.correct
        @set('cloze_text', data.challenge.en_text)
      else
        @set('cloze_text', data.mistake.cloze_text)

  submitRawText: ->
    @_resolveRawText().done (data) =>
      if data.correct
        @set('cloze_text', data.challenge.en_text)
        @trigger('correct', data)
      else
        @set('cloze_text', data.mistake.cloze_text)
        @trigger('notification', data.mistake.message)

  fetchPartialAnswer: ->
    $.ajax("#{@url()}/partial_answer",
      type: 'POST'
      dataType: 'json'
      data: {raw_text: @get('raw_text')}
    ).done (data) =>
      if data.mistake
        @set('raw_text', data.mistake.partial_answer)

  fetchWords: ->
    $.ajax(@url(),
      type: 'GET'
      dataType: 'json'
      data: {require_words: true}
    ).done (data) =>
      @set('words', data.words)

  fetchCorrectText: ->
    $.ajax(@url(),
      type: 'GET'
      dataType: 'json'
      data: {require_correct_text: true}
    ).done (data) =>
      @set('correct_text', data.correct_text)

  _resolveRawText: ->
    $.ajax("#{@url()}/resolving",
      type: 'POST'
      dataType: 'json'
      data: {raw_text: @get('raw_text')}
    )

app.Collections.ChallengeCollection = Backbone.Collection.extend
  model: app.Models.Challenge
  initialize: (course_id) ->
    @url = "/courses/#{course_id}/challenges"
