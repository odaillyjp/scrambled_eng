app = @ScrambledEng
app.Models ?= {}

app.Models.Challenge = Backbone.Model.extend
  initialize: ->
    @listenTo @, 'change:raw_text', _.debounce =>
      @fetchHiddenText()
    , 500

  fetchHiddenText: ->
    @_resolveRawText().done (data) =>
      if data.correct
        @set('hidden_text', data.challenge.en_text)
      else
        @set('hidden_text', data.mistake.hidden_text)

  submitRawText: ->
    @_resolveRawText().done (data) =>
      if data.correct
        @set('hidden_text', data.challenge.en_text)
        @trigger('correct', data)
      else
        @set('hidden_text', data.mistake.hidden_text)
        @trigger('notification', data.mistake.message)

  fetchNextWord: ->
    $.ajax("#{@url()}/next_word",
      type: 'POST'
      dataType: 'json'
      data: {raw_text: @get('raw_text')}
    ).done (data) =>
      @set('raw_text', [@get('raw_text'), data.next_word].join(' '))

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
