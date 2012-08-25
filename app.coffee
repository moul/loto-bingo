app = require('../kickstart2')(require './config').app()

routes = require './routes'
app.get  '/',           routes.index
app.get  '/login',      routes.login.login

app.run()
