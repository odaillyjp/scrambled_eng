#= require_tree ../../templates

app = @ScrambledEng
app.Views.Challenges ?= {}

app.Views.Challenges.IncorrectModalView = Backbone.View.extend
  className: 'challenge-incorrect-modal'
  template: JST['challenges/incorrect_modal']

  render: ->
    @$el.html(@template())
    @
