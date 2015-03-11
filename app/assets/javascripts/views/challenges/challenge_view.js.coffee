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
    @listenTo @model, 'change:hidden_text', @render
    @listenTo @model, 'correct', @renderCorrectModal
    @listenTo @model, 'notification', @renderNotificationModal

  render: ->
    @$el.html(@template(@model.toJSON()))
    @stickit()
    @

  renderCorrectModal: (data) ->
    correctModalView = new app.Views.Challenges.CorrectModalView(data)
    @$el.append(correctModalView.render().el)
    @listenTo @, 'submit', ->
      correctModalView.remove()

  renderNotificationModal: ->
    notificationView = new app.Views.Challenges.NotificationView
    @$el.append(notificationView.render().el)
    @listenTo @, 'submit', ->
      notigicationView.remove()
