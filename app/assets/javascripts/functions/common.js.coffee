@._common =
  is_number: (str) ->
    str.match(/^\d+$/)

  add_month: (date, months) ->
    date.setMonth(date.getMonth() + months)
    date
