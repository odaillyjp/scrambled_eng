#= require_tree ../../templates

app = @ScrambledEng
app.Views.Challenges ?= {}

app.Views.Challenges.InformationView = Backbone.View.extend
  template: JST['challenges/information']

  events:
    'click .challenge-start-button': 'navigateToChallenge'

  initialize: ->
    @listenTo @collection, 'reset', =>
      @render()

  render: ->
    context = {}
    firstChallenge = @collection.first()
    _.extend(context, firstChallengeUrl: firstChallenge.get('url'))
    _.extend(context, courseName: firstChallenge.get('course_name'))
    @$el.html(@template(context))
    @

  navigateToChallenge: (e) ->
    e.preventDefault()
    Backbone.history.navigate(@collection.first().url(), true)
