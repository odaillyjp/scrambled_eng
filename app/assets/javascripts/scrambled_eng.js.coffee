#= require_self
#= require_tree ./routers
#= require_tree ./models
#= require_tree ./views

'use strict'

@ScrambledEng =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}

  init: ->
    new ScrambledEng.Routers.ApplicationRouter
    Backbone.history.start(pushState: true)

$ ->
  ScrambledEng.init()
