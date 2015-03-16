#= require_tree ../../templates

app = @ScrambledEng
app.Views.Challenges ?= {}

app.Views.Challenges.ChallengeView = Backbone.View.extend
  template: JST['challenges/challenge']

  events:
    'click .challenge-tab-item__cloze-text-link': 'renderClozeTextPanel'
    'click .challenge-tab-item__hints-link': 'renderHintsPanel'
    'click .editer-panel__submit-raw-text-button': 'submitRawText'

  bindings:
    '#input-challenge-raw_text': 'raw_text'

  submitRawText: ->
    @model.submitRawText()
    @trigger('submit')

  initialize: ->
    @clozeTextPanelView = new app.Views.Challenges.ClozeTextPanelView(model: @model)
    @hintsPanelView = new app.Views.Challenges.HintsPanelView(model: @model)
    @hintsPanelView.$el.addClass('is-hidden')
    @listenTo @model, 'correct', @renderCorrectModal
    @listenTo @model, 'notification', @renderNotification

  render: ->
    @$el.html(@template(@model.toJSON()))
    @$('.challenge-panel').append(@clozeTextPanelView.render().el)
    @$('.challenge-panel').append(@hintsPanelView.render().el)
    @stickit()
    @

  renderClozeTextPanel: ->
    @$('.hints-tab-link').removeClass('is-current')
    @$('.english-tab-link').addClass('is-current')
    @hintsPanelView.$el.addClass('is-hidden')
    @clozeTextPanelView.$el.removeClass('is-hidden')

  renderHintsPanel: ->
    @$('.english-tab-link').removeClass('is-current')
    @$('.hints-tab-link').addClass('is-current')
    @clozeTextPanelView.$el.addClass('is-hidden')
    @hintsPanelView.$el.removeClass('is-hidden')

  renderCorrectModal: (data) ->
    correctModalView = new app.Views.Challenges.CorrectModalView(data)
    @$el.append(correctModalView.render().el)
    @listenTo @, 'submit', ->
      correctModalView.remove()

  renderNotification: (message) ->
    notificationView = new app.Views.Challenges.NotificationView(message)
    @$el.append(notificationView.render().el)
    @listenTo @, 'submit', ->
      notificationView.remove()
