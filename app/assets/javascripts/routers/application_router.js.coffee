app = @ScrambledEng
app.Routers ?= {}

app.Routers.ApplicationRouter = Backbone.Router.extend
  initialize: ->
    @layout = new app.Views.LayoutView(el: $('body'))
    @challenges = null
    @__on_dropdown_menu_event()
    @__on_notice_event()
    @__subRouters =
      'challenges': new app.Routers.ChallengesRouter(@layout, @challenges)
      'courses':    new app.Routers.CoursesRouter(@layout, @challenges)
      'users':      new app.Routers.UsersRouter()

  __on_dropdown_menu_event: ->
    # ヘッダーのドロップダウンメニュー
    $(document).on 'click', '.header__dropdown-menu-link', ->
      $('.header__dropdown-menu').toggleClass('is-hidden')
      false

  __on_notice_event: ->
    # お知らせメッセージの削除イベント
    $(document).on 'click', '.main__notice', ->
      $('.main__notice').hide()
      false
