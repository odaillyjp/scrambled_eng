app = @ScrambledEng
app.Routers ?= {}

app.Routers.ApplicationRouter = Backbone.Router.extend
  routes:
    'courses/:course_id/challenges/:challenge_id' : 'showChallenge'
    'courses/:course_id': 'indexChallenge'

  initialize: ->
    @layout = new app.Views.LayoutView(el: $('body'))
    @challenges = null

  indexChallenge: (course_id) ->
    @__fetchChallenges(course_id)
    @__renderSidebarView(course_id)
    informationView = new app.Views.Challenges.InformationView(collection: @challenges)
    @layout.setMainView(informationView)

  showChallenge: (course_id, challenge_id) ->
    @__fetchChallenges(course_id)
    @__renderSidebarView(course_id)
    @challenge = @challenges.get(challenge_id)
    if @challenge
      @__renderChallengeView()
    else
      @challenge = new app.Models.Challenge(id: challenge_id)
      @challenge.urlRoot = "/courses/#{course_id}/challenges"
      @challenge.fetch(success: => @__renderChallengeView())

  __fetchChallenges: (course_id) ->
    @challenges = new app.Collections.ChallengeCollection(course_id)
    @challenges.fetch(reset: true)

  __renderSidebarView: (course_id) ->
    sidebarView = new app.Views.Challenges.SidebarView(collection: @challenges)
    @layout.setSidebarView(sidebarView)

  __renderChallengeView: ->
    challengeView = new app.Views.Challenges.ChallengeView(model: @challenge)
    @layout.setMainView(challengeView)
