#= require_tree ../../templates

app = @ScrambledEng
app.Views.Challenges ?= {}

app.Views.Challenges.HintsPanelView = Backbone.View.extend
  className: 'hints-panel'
  template: JST['challenges/hints_panel']

  events:
    'click .hints-panel__get-words-button': 'fetchWords'
    'click .hints-panel__get-correct-text-button': 'fetchCorrectText'

  initialize: ->
    @listenTo @model, 'change:words', @render
    @listenTo @model, 'change:correct_text', @render

  render: ->
    @$el.html(@template(@model.toJSON()))
    @

  fetchWords: ->
    @model.fetchWords()

  fetchCorrectText: ->
    @model.fetchCorrectText()
