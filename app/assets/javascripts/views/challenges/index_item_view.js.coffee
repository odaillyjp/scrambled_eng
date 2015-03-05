#= require_tree ../../templates

app = @ScrambledEng
app.Views.Challenges ?= {}

app.Views.Challenges.IndexItemView = Backbone.View.extend
  tagName: 'li'
  id: -> "challenge_#{@model.id}"
  className: 'challenge-sidebar-nav-item'
  template: JST['challenges/index_item']

  render: ->
    @$el.html(@template(@model.toJSON()))
    @
