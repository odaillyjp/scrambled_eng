#= require_tree ../../templates

app = @ScrambledEng
app.Views.Challenges ?= {}

app.Views.Challenges.SidebarView = Backbone.View.extend
  className: 'sidebar'
  template: JST['challenges/sidebar']

  initialize: ->
    @listenTo @collection, 'reset', =>
      @render()

  render: ->
    context = {}
    firstChallenge = @collection.first()
    _.extend(context, courseName: firstChallenge.get('course_name'))
    @$el.html(@template(context))
    @collection.each (challenge) =>
      view = new app.Views.Challenges.SidebarItemView(model: challenge)
      @$('.challenge-list').append(view.render().el)
    @
