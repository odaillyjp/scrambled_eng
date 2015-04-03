app = @ScrambledEng
app.Routers ?= {}

app.Routers.ApplicationRouter = Backbone.Router.extend
  routes:
    'courses/:course_id/challenges/:challenge_id' : 'showChallenge'
    'courses/:course_id': 'indexChallenge'

  initialize: ->
    @layout = new app.Views.LayoutView(el: $('body'))
    @challenges = null
    @__on_dropdown_menu_event()

  indexChallenge: (course_id) ->
    unless @challenges
      @__fetchChallenges(course_id)
      @__renderSidebarView(course_id)
    informationView = new app.Views.Challenges.InformationView(collection: @challenges)
    @layout.setMainView(informationView)

  showChallenge: (course_id, challenge_id) ->
    if @challenges
      @__renderChallengeView(challenge_id)
    else
      @__fetchChallenges(course_id).success =>
        @__renderSidebarView(course_id)
        @__renderChallengeView(challenge_id)

  __on_dropdown_menu_event: ->
    # ヘッダーのドロップダウンメニュー
    $(document).on 'click', '.header__dropdown-menu-link', ->
      $('.header__dropdown-menu').toggleClass('is-hidden')
      false

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
