app = @ScrambledEng
app.Models ?= {}

app.Models.Challenge = Backbone.Model.extend
  renderText: ->
    $.ajax("/courses/#{@get('course_id')}/challenges/#{@get('challenge_id')}/resolving",
      type: 'POST'
      dataType: 'json'
      data: {raw_text: @get('raw_text')}
    ).done (data) =>
      @set('hidden_text', data.body)

app.Collections.ChallengeCollection = Backbone.Collection.extend
  model: app.Models.Challenge
  initialize: (course_id) ->
    @url = "/courses/#{course_id}/challenges"
