#= require_tree ../../templates

app = @ScrambledEng
app.Views.Challenges ?= {}

app.Views.Challenges.HintsPanelView = Backbone.View.extend
  className: 'hints-panel'
  template: JST['challenges/hints_panel']

  events:
    'click .hints-panel__get-hint-button': 'getChallengeHint'

  initialize: ->
    @listenTo @model, 'change:words', @render

  render: ->
    @$el.html(@template(@model.toJSON()))
    @

  getChallengeHint: ->
    @model.getWords()
