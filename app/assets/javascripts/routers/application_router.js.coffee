app = @ScrambledEng
app.Routers ?= {}

app.Routers.ApplicationRouter = Backbone.Router.extend
  routes:
    'courses/:course_id/challenges/:challenge_id' : 'showChallenge'
    'courses/:course_id/management': 'manageCourse'
    'courses/:course_id': 'indexCourse'
    'users/:user_id': 'showUser'

  initialize: ->
    @layout = new app.Views.LayoutView(el: $('body'))
    @challenges = null
    @__on_dropdown_menu_event()
    @__on_notice_event()

  showChallenge: (course_id, challenge_id) ->
    # new や edit の場合は処理しない
    return false unless @__is_number(challenge_id)

    if @challenges
      @__renderChallengeView(challenge_id)
    else
      @__fetchChallenges(course_id).success =>
        @__renderSidebarView(course_id)
        @__renderChallengeView(challenge_id)

  manageCourse: (course_id) ->
    cal = new CalHeatMap()
    cal.init(
      itemSelector: '.course-management__heatmap-box',
      domain: 'month',
      subDomain: 'x_day'
      cellSize: 20,
      range: 1,
      data: "/histories/heatmap?course_id=#{course_id}&from={{d:start}}&to={{d:end}}",
      dataType: 'json',
      domainLabelFormat: '',
      subDomainTextFormat: '%d',
      displayLegend: false)

  indexCourse: (course_id) ->
    # new や edit の場合は処理しない
    return false unless @__is_number(course_id)

    unless @challenges
      @__fetchChallenges(course_id)
      @__renderSidebarView(course_id)
    informationView = new app.Views.Challenges.InformationView(collection: @challenges)
    @layout.setMainView(informationView)

  showUser: (user_id) ->
    # new や edit の場合は処理しない
    return false unless @__is_number(user_id)

    cal = new CalHeatMap()
    cal.init(
      itemSelector: '.user__heatmap-box',
      domain: 'month',
      subDomain: 'day'
      range: 6,
      data: "/histories/heatmap?user_id=#{user_id}&from={{d:start}}&to={{d:end}}",
      dataType: 'json',
      displayLegend: false,
      start: do ->
        today = new Date()
        today.setMonth(today.getMonth() - 5)
        console.log(today)
        today
    )

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

  __is_number: (id) ->
    id.match(/^\d+$/)

  __fetchChallenges: (course_id) ->
    @challenges = new app.Collections.ChallengeCollection(course_id)
    @challenges.fetch(reset: true)

  __renderSidebarView: (course_id) ->
    sidebarView = new app.Views.Challenges.SidebarView(collection: @challenges)
    @layout.setSidebarView(sidebarView)

  __renderChallengeView: (challenge_id) ->
    @challenge = @challenges.get(challenge_id)
    @challenges.select(@challenge)
    challengeView = new app.Views.Challenges.ChallengeView(model: @challenge)
    @layout.setMainView(challengeView)
