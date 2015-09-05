app = @ScrambledEng
app.Routers ?= {}

app.Routers.CoursesRouter = Backbone.Router.extend
  routes:
    'courses/:course_id/management': 'manageCourse'
    'courses/:course_id': 'indexCourse'

  initialize: (@layout, @challenges) ->

  manageCourse: (course_id) ->
    monthRange = 3
    cal = new CalHeatMap()
    cal.init(
      itemSelector: '.course-management__heatmap-container',
      domain: 'month',
      subDomain: 'day'
      range: monthRange,
      data: "/histories/heatmap?course_id=#{course_id}&from={{d:start}}&to={{d:end}}",
      dataType: 'json',
      displayLegend: false,
      domainMargin: [12, 4],
      legend: [5, 10, 15, 20, 25],
      start: _common.add_month(new Date(), (1 - monthRange))
    )

    new app.Views.Challenges.ManagementListView()

  indexCourse: (course_id) ->
    # new や edit の場合は処理しない
    return false unless _common.is_number(course_id)

    unless @challenges
      @__fetchChallenges(course_id).success =>
        @__renderSidebarView(course_id)
        $('#splash').fadeOut(500)
    informationView = new app.Views.Challenges.InformationView(collection: @challenges)
    @layout.setViewToMainContainer(informationView)

  __fetchChallenges: (course_id) ->
    @challenges = new app.Collections.ChallengeCollection(course_id)
    @challenges.fetch(reset: true)

  __renderSidebarView: (course_id) ->
    sidebarView = new app.Views.Challenges.SidebarView(collection: @challenges)
    @layout.setViewToSidebarContainer(sidebarView)
