#!/usr/bin/env coffee

config = require './config'
tapas = require('tapas')(config.tapas).app()

tapas.autodiscover './controllers'

do tapas.run
