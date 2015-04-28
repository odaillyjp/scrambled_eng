app = @ScrambledEng
app.Routers ?= {}

app.Routers.UsersRouter = Backbone.Router.extend
  routes:
    'users/:user_id': 'showUser'

  showUser: (user_id) ->
    # new や edit の場合は処理しない
    return false unless _common.is_number(user_id)

    monthRange = 3
    cal = new CalHeatMap()
    cal.init(
      itemSelector: '.user__heatmap-box',
      domain: 'month',
      subDomain: 'x_day',
      cellSize: 20,
      range: monthRange,
      data: "/histories/heatmap?user_id=#{user_id}&from={{d:start}}&to={{d:end}}",
      dataType: 'json',
      displayLegend: false,
      domainMargin: 10,
      subDomainTextFormat: '%d',
      legend: [4, 8, 12, 16, 20],
      start: _common.add_month(new Date(), (1 - monthRange))
    )

    $(document).on 'click', '.user__delete-user-link', ->
      deleteConfirmModalView = new app.Views.Users.DeleteConfirmModalView(user_id: user_id)
      $('.user').append(deleteConfirmModalView.render().el)
      false
