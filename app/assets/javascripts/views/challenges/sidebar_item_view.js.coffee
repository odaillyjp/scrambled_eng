#= require_tree ../../templates

app = @ScrambledEng
app.Views.Challenges ?= {}

app.Views.Challenges.SidebarItemView = Backbone.View.extend
  tagName: 'li'
  id: -> "challenge_#{@model.id}"
  className: 'sidebar-item'
  template: JST['challenges/sidebar_item']

  events:
    'click .sidebar-item__challenge-link': 'navigateToChallenge'

  initialize: ->
    @listenTo @model, 'selected', @addCurrentClass
    @listenTo @model, 'deselected', @removeCurrentClass

  render: ->
    content = @model.toJSON()
    _.extend(content, lead: @model.textToLead())
    @$el.html(@template(content))
    @

  navigateToChallenge: (e) ->
    e.preventDefault()
    Backbone.history.navigate(@model.url(), true)

  addCurrentClass: ->
    @$('.sidebar-item__challenge-link').addClass('is-current')

  removeCurrentClass: ->
    @$('.sidebar-item__challenge-link').removeClass('is-current')
