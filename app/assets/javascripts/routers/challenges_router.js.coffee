app = @ScrambledEng
app.Routers ?= {}

app.Routers.ChallengesRouter = Backbone.Router.extend
  routes:
    'courses/:course_id/challenges/:challenge_id' : 'showChallenge'

  initialize: (@layout, @challenges) ->

  showChallenge: (course_id, challenge_id) ->
    # new や edit の場合は処理しない
    return false unless _common.is_number(challenge_id)

    if @challenges
      @__renderChallengeView(challenge_id)
    else
      @__fetchChallenges(course_id).success =>
        @__renderSidebarView(course_id)
        @__renderChallengeView(challenge_id)

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
