ks =                    require '../kickstart2'
ks.config =             require './config'
app =                   ks.app()

console.log app
app.initialize()

routes =                require './routes'
#app.get  '/',           routes.index
#app.get  '/login',      routes.login.login
console.dir app.get
#app.use...

app.start()
