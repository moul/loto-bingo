app = require('../kickstart2')(require './config').app()

#routes = require './routes'
#app.get  '/',                           routes.index
#app.get  '/login',                      routes.login.login
#app.get  '/bingo',      app.restrict,   routes.bingo.index
#app.get  '/bingo/list', app.restrict,   routes.bingo.list

app.autodiscover "./controllers"

#console.log '==========================================='
#for subpath, subapp of app.subapps
#        console.log subpath
#        console.dir subapp.config.dirs
#console.log '==========================================='

do app.run
