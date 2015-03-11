#= require_tree ../../templates

app = @ScrambledEng
app.Views.Challenges ?= {}

app.Views.Challenges.HiddenTextPanelView = Backbone.View.extend
  className: 'hidden-text-panel'
  template: JST['challenges/hidden_text_panel']

  initialize: ->
    @listenTo @model, 'change:hidden_text', @render

  render: ->
    @$el.html(@template(@model.toJSON()))
    @
