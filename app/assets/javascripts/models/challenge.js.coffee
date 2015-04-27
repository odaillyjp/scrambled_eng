app = @ScrambledEng
app.Models ?= {}

app.Models.Challenge = Backbone.Model.extend
  initialize: ->
    Backbone.Select.Me.applyTo(@)
    @listenTo @, 'change:raw_text', _.debounce =>
      @fetchHiddenText()
    , 300

  textToLead: (maxLength = 8) ->
    ja_text = @get('ja_text')
    "#{ja_text.substr(0, maxLength)}..." if ja_text

  submitRawText: ->
    @_findMistake().done (data) =>
      if data.correct
        @set('cloze_text', data.challenge.en_text)
        @trigger('correct', data)
      else
        @set('cloze_text', data.mistake.cloze_text)
        @trigger('notification', data.mistake.message)

  fetchHiddenText: ->
    @_findMistake(require_cloze_text: true).done (data) =>
      @set('cloze_text', data.cloze_text)

  fetchPartialAnswer: ->
    @_findMistake(require_partial_answer: true).done (data) =>
      unless data.correct
        @set('raw_text', data.mistake.partial_answer)
        @set('cloze_text', data.mistake.cloze_text)

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

  _findMistake: (data) ->
    data = _.extend({raw_text: @get('raw_text')}, data)

    $.ajax("#{@url()}/mistake",
      type: 'POST'
      dataType: 'json'
      data: data
    )

app.Collections.ChallengeCollection = Backbone.Collection.extend
  model: app.Models.Challenge
  initialize: (course_id) ->
    Backbone.Select.One.applyTo(@, [])
    @url = "/courses/#{course_id}/challenges"
