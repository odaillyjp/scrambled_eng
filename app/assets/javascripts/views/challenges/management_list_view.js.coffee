#= require_tree ../../templates

app = @ScrambledEng
app.Views.Challenges ?= {}

app.Views.Challenges.ManagementListView = Backbone.View.extend
  el: '.course-management__challenge-list'

  events:
    'click .course-management__challenge-delete-link': 'showDeleteConfirmModal'

  showDeleteConfirmModal: (e) ->
    elem = @$(e.target).parents('.course-management__challenge-item')
    course_id = elem.data('courseId')
    challenge_id = elem.data('challengeId')
    ja_text = elem.find('.course-management__challenge-ja-text').text()

    deleteConfirmModalView = new app.Views.Challenges.DeleteConfirmModalView(course_id: course_id, challenge_id: challenge_id, ja_text: ja_text)
    @$el.append(deleteConfirmModalView.render().el)
