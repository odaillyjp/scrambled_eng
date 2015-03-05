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
        console.log('正解')
      else
        @set('hide_en_text', data.mistake)

app.Collections.ChallengeCollection = Backbone.Collection.extend
  model: app.Models.Challenge
  initialize: (course_id) ->
    @url = "/courses/#{course_id}/challenges"
