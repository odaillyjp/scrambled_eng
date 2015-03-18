#= require_tree ../../templates

app = @ScrambledEng
app.Views.Challenges ?= {}

app.Views.Challenges.CorrectModalView = Backbone.View.extend
  className: 'correct-modal'
  template: JST['challenges/correct_modal']

  events:
    'click .overlay': 'remove'

  initialize: (data) ->
    @resultData = _.pick(data, 'next_challenge_url', 'course_information_url')
    if data.challenge.sequence_number
      @resultData.message = "You've Successfully Completed Challenge #{data.challenge.sequence_number}!"
    else
      @resultData.message = "Congratulations, You've Completed This Course!"

  render: ->
    @$el.html(@template(@resultData))
    @
