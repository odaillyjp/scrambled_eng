#= require_tree ../../templates

app = @ScrambledEng
app.Views.Challenges ?= {}

app.Views.Challenges.CorrectModalView = Backbone.View.extend
  className: 'challenge-correct-modal'
  template: JST['challenges/correct_modal']

  initialize: (data) ->
    @resultData = _.pick(data, 'next_challenge_url', 'course_information_url')

  render: ->
    @$el.html(@template(@resultData))
    @