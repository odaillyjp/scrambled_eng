#= require_tree ../../templates

app = @ScrambledEng
app.Views.Challenges ?= {}

app.Views.Challenges.NotificationView = Backbone.View.extend
  className: 'challenge-view__notification'
  template: JST['challenges/notification']

  events:
    'click': 'remove'

  initialize: (@message) ->

  render: ->
    @$el.html(@template(message: @message))
    @
