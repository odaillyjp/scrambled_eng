#= require_tree ../../templates

app = @ScrambledEng
app.Views.Challenges ?= {}

app.Views.Challenges.ClozeTextPanelView = Backbone.View.extend
  className: 'cloze-text-panel'
  template: JST['challenges/cloze_text_panel']

  events:
    'click .cloze-text-panel__get-next-word-button': 'fetchPartialAnswer'

  initialize: ->
    @listenTo @model, 'change:cloze_text', @render

  render: ->
    @$el.html(@template(@model.toJSON()))
    @

  fetchPartialAnswer: ->
    @$('.cloze-text-panel__get-next-word-button').addClass('is-submitting')
    @model.fetchPartialAnswer().done =>
      @$('.cloze-text-panel__get-next-word-button').removeClass('is-submitting')
