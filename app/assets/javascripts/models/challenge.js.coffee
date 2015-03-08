app = @ScrambledEng
app.Models ?= {}

app.Models.Challenge = Backbone.Model.extend
  submitRawText: ->
    $.ajax("#{@url()}/resolving",
      type: 'POST'
      dataType: 'json'
      data: {raw_text: @get('raw_text')}
    ).done (data) =>
      if data.correct
        @set('hidden_text', data.challenge.en_text)
        @trigger('correct', data)
      else
        @set('hidden_text', data.mistake)
        @trigger('incorrect')

app.Collections.ChallengeCollection = Backbone.Collection.extend
  model: app.Models.Challenge
  initialize: (course_id) ->
    @url = "/courses/#{course_id}/challenges"
