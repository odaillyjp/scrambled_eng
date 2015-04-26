#= require_tree ../../templates

app = @ScrambledEng
app.Views.Challenges ?= {}

app.Views.Challenges.ChallengeView = Backbone.View.extend
  className: 'challenge'
  template: JST['challenges/challenge']
  challengePanelContainer: '.challenge__panel-container'

  events:
    'click .challenge-tab-item__cloze-text-link': 'renderClozeTextPanel'
    'click .challenge-tab-item__hints-link': 'renderHintsPanel'
    'click .editer-panel__submit-raw-text-button': 'submitRawText'

  bindings:
    '#input-challenge-raw_text': 'raw_text'

  initialize: ->
    @clozeTextPanelView = new app.Views.Challenges.ClozeTextPanelView(model: @model)
    @hintsPanelView = new app.Views.Challenges.HintsPanelView(model: @model)
    @hintsPanelView.$el.addClass('is-hidden')
    @listenTo @model, 'correct', @renderCorrectModal
    @listenTo @model, 'notification', @renderNotification

  render: ->
    @$el.html(@template(@model.toJSON()))
    @$(@challengePanelContainer).append(@clozeTextPanelView.render().el)
    @$(@challengePanelContainer).append(@hintsPanelView.render().el)
    @stickit()
    @

  renderClozeTextPanel: ->
    @$('.challenge-tab-item__hints-link').removeClass('is-current')
    @$('.challenge-tab-item__cloze-text-link').addClass('is-current')
    @hintsPanelView.$el.addClass('is-hidden')
    @clozeTextPanelView.$el.removeClass('is-hidden')

  renderHintsPanel: ->
    @$('.challenge-tab-item__cloze-text-link').removeClass('is-current')
    @$('.challenge-tab-item__hints-link').addClass('is-current')
    @clozeTextPanelView.$el.addClass('is-hidden')
    @hintsPanelView.$el.removeClass('is-hidden')

  submitRawText: ->
    @$('.editer-panel__submit-raw-text-button').addClass('is-submitting')
    @model.submitRawText().done =>
      @$('.editer-panel__submit-raw-text-button').removeClass('is-submitting')
    @trigger('submit')

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
