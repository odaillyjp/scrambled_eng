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
    @hiddenTextPanelView = new app.Views.Challenges.HiddenTextPanelView(model: @model)
    @listenTo @model, 'correct', @renderCorrectModal
    @listenTo @model, 'notification', @renderNotification

  render: ->
    @$el.html(@template(@model.toJSON()))
    @$('.challenge-panel').append(@hiddenTextPanelView.render().el)
    @stickit()
    @

  renderCorrectModal: (data) ->
    correctModalView = new app.Views.Challenges.CorrectModalView(data)
    @$el.append(correctModalView.render().el)
    @listenTo @, 'submit', ->
      correctModalView.remove()

  renderNotification: ->
    notificationView = new app.Views.Challenges.NotificationView
    @$el.append(notificationView.render().el)
    @listenTo @, 'submit', ->
      notificationView.remove()
