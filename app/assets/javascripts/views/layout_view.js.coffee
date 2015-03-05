app = @ScrambledEng
app.Views ?= {}

app.Views.LayoutView = Backbone.View.extend
  mainViewContainer: '#main-container'
  sidebarViewContainer: '#sidebar-container'
  currentMainView: null
  currentSidebarView: null

  setMainView: (mainView) ->
    @_setView(@mainViewContainer, @currentMainView, mainView)

  setSidebarView: (sidebarView) ->
    @_setView(@sidebarViewContainer, @currentSidebarView, sidebarView)

  _setView: (viewContainer, currentView, view) ->
    currentView.remove() if currentView
    currentView = view
    @$(viewContainer).html(view.render().el)
