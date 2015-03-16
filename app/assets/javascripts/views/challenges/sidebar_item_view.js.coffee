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
    content = @model.toJSON()
    _.extend(content, lead: @model.textToLead())
    @$el.html(@template(content))
    @

  navigateToChallenge: (e) ->
    e.preventDefault()
    Backbone.history.navigate(@model.url(), true)
