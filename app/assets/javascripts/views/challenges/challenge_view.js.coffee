#= require_tree ../../templates

app = @ScrambledEng
app.Views.Challenges ?= {}

app.Views.Challenges.ChallengeView = Backbone.View.extend
  template: JST['challenges/challenge']

  events:
    'click .challenge-submit-button': 'submitRawText'

  bindings:
    '#input-challenge-raw_text': 'raw_text'

  submitRawText: ->
    @model.submitRawText()

  initialize: ->
    @listenTo @model, 'change:hide_en_text', @render

  render: ->
    @$el.html(@template(@model.toJSON()))
    @stickit()
    @
