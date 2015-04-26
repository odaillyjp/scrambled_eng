#= require_tree ../../templates

app = @ScrambledEng
app.Views.Challenges ?= {}

app.Views.Challenges.DeleteConfirmModalView = Backbone.View.extend
  className: 'delete-confirm-modal'
  template: JST['challenges/delete_confirm_modal']

  events:
    'click .overlay': 'remove'
    'click .delete-confirm-modal__cancel-button': 'remove'

  initialize: (data) ->
    @content = _.pick(data, 'ja_text', 'course_id', 'challenge_id')

  render: ->
    @$el.html(@template(@content))
    @
