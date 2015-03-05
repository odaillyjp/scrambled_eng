app = @ScrambledEng
app.Views ?= {}

app.Views.LayoutView = Backbone.View.extend
  viewContainer: '#main-container'
  currentView: null

  setView: (view) ->
    @currentView.remove() if @currentView
    @currentView = view
    @$(@viewContainer).html(view.render().el)
