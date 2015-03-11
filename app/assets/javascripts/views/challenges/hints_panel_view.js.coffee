#= require_tree ../../templates

app = @ScrambledEng
app.Views.Challenges ?= {}

app.Views.Challenges.HintsPanelView = Backbone.View.extend
  className: 'hints-panel'
  template: JST['challenges/hints_panel']

  render: ->
    @$el.html(@template(@model.toJSON()))
    @
