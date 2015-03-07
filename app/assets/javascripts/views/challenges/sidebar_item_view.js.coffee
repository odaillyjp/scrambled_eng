#= require_tree ../../templates

app = @ScrambledEng
app.Views.Challenges ?= {}

app.Views.Challenges.SidebarItemView = Backbone.View.extend
  tagName: 'li'
  id: -> "challenge_#{@model.id}"
  className: 'challenge-sidebar-nav-item'
  template: JST['challenges/sidebar_item']

  events:
    'click .challenge-sidebar-link': 'navigateToChallenge'

  render: ->
    @$el.html(@template(@model.toJSON()))
    @

  navigateToChallenge: (e) ->
    e.preventDefault()
    Backbone.history.navigate(@model.url(), true)
