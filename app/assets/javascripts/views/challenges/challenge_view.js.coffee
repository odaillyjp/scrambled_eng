#= require_tree ../../templates

app = @ScrambledEng
app.Views.Challenges ?= {}

app.Views.Challenges.ChallengeView = Backbone.View.extend
  template: JST['challenges/challenge']

  events:
    'click .challenge-submit-button': 'submitRawText'
    'click .english-tab-link': 'renderHiddenTextPanel'
    'click .hints-tab-link': 'renderHintsPanel'

  bindings:
    '#input-challenge-raw_text': 'raw_text'

  submitRawText: ->
    @model.submitRawText()
    @trigger('submit')

  initialize: ->
    @hiddenTextPanelView = new app.Views.Challenges.HiddenTextPanelView(model: @model)
    @hintsPanelView = new app.Views.Challenges.HintsPanelView(model: @model)
    @listenTo @model, 'correct', @renderCorrectModal
    @listenTo @model, 'notification', @renderNotification

  render: ->
    @$el.html(@template(@model.toJSON()))
    @$('.challenge-panel').append(@hiddenTextPanelView.render().el)
    @stickit()
    @

  renderHiddenTextPanel: ->
    @$('.hints-tab-link').removeClass('is-current')
    @$('.english-tab-link').addClass('is-current')
    @hintsPanelView.remove()
    @$('.challenge-panel').append(@hiddenTextPanelView.render().el)

  renderHintsPanel: ->
    @$('.english-tab-link').removeClass('is-current')
    @$('.hints-tab-link').addClass('is-current')
    @hiddenTextPanelView.remove()
    @$('.challenge-panel').append(@hintsPanelView.render().el)

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
