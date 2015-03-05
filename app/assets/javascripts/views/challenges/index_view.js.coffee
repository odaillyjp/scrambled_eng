#= require_tree ../../templates

app = @ScrambledEng
app.Views.Challenges ?= {}

app.Views.Challenges.IndexView = Backbone.View.extend
  template: JST['challenges/index']

  initialize: ->
    @listenTo @collection, 'reset', =>
      @render()

  render: ->
    context = {}
    firstChallenge = @collection.first()
    _.extend(context, firstChallengeUrl: firstChallenge.get('url'))
    _.extend(context, courseName: firstChallenge.get('course_name'))
    @$el.html(@template(context))
    @collection.each (challenge) =>
      view = new app.Views.Challenges.IndexItemView(model: challenge)
      @$('.challenge-list').append(view.render().el)
    @
