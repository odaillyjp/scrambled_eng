app = @ScrambledEng
app.Views ?= {}

app.Views.LayoutView = Backbone.View.extend
  mainSelector: '#main'
  mainContainerSelector: '#main-container'
  sidebarContainerSelector: '#sidebar-container'
  currentMainView: null
  currentMainContainerView: null
  currentSidebarView: null

  setViewToMain: (view) ->
    @_set(@mainSelector, 'currentMainView', view)

  setViewToMainContainer: (view) ->
    @_setView(@mainContainerSelector, 'currentMainContainerView', view)

  setViewToSidebarContainer: (view) ->
    @_setView(@sidebarContainerSelector, 'currentSidebarContainerView', view)

  _setView: (selector, memorizationId, view) ->
    @[memorizationId].remove() if @[memorizationId]
    @[memorizationId] = view
    @$(selector).html(view.render().el)
