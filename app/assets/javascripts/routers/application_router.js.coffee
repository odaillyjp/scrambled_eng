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
    indexView = new app.Views.Challenges.IndexView(collection: @challenges)
    @layout.setView(indexView)

  showChallenge: (course_id, challenge_id) ->
    @__fetchChallenges(course_id)
    @challenge = @challenges.get(challenge_id)
    if @challenge
      challengeView = new app.Views.ChallengeView(model: @challenge)
      @layout.setView(challengeView)

  __fetchChallenges: (course_id) ->
    @challenges = new app.Collections.ChallengeCollection(course_id)
    @challenges.fetch(reset: true)
