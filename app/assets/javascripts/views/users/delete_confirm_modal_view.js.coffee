#= require_tree ../../templates

app = @ScrambledEng
app.Views.Users ?= {}

app.Views.Users.DeleteConfirmModalView = Backbone.View.extend
  className: 'delete-confirm-modal'
  template: JST['users/delete_confirm_modal']

  events:
    'click .overlay': 'remove'
    'click .delete-confirm-modal__cancel-button': 'remove'

  initialize: (data) ->
    @content = _.pick(data, 'user_id')

  render: ->
    @$el.html(@template(@content))
    @
