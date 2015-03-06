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
    @trigger('submit')

  initialize: ->
    @listenTo @model, 'change:hide_en_text', @render
    @listenTo @model, 'correct', @renderCorrectModal
    @listenTo @model, 'incorrect', @renderIncorrectModal

  render: ->
    @$el.html(@template(@model.toJSON()))
    @stickit()
    @

  renderCorrectModal: ->

  renderIncorrectModal: ->
    incorrectModalView = new app.Views.Challenges.IncorrectModalView
    @$el.append(incorrectModalView.render().el)
    @listenTo @, 'submit', ->
      incorrectModalView.remove()
