app = require('../kickstart2')(require './config').app()

routes = require './routes'
app.get  '/',                           routes.index
app.get  '/login',                      routes.login.login
#app.get  '/bingo',      app.restrict,   routes.bingo.index
#app.get  '/bingo/list', app.restrict,   routes.bingo.list

app.run()
