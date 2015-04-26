#= require_tree ../../templates

app = @ScrambledEng
app.Views.Challenges ?= {}

app.Views.Challenges.ManagementListView = Backbone.View.extend
  el: '.course-management__challenge-list'

  events:
    'click .course-management__challenge-delete-link': 'showDeleteConfirmModal'

  showDeleteConfirmModal: (e) ->
    ja_text = @$(e.target).parents('.course-management__challenge-item')
      .find('.course-management__challenge-ja-text')
      .text()
    deleteConfirmModalView = new app.Views.Challenges.DeleteConfirmModalView(ja_text: ja_text)
    @$el.append(deleteConfirmModalView.render().el)
