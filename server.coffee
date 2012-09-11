process.on 'uncaughtException', (err) -> console.log "Caught uncaughtException: #{err.stack}"

#require.paths.unshift "#{__dirname}/lib", "#{__dirname}"

settings = require './settings'

if process.env.DB_HOST
        settings.db.url = process.env.DB_URL

everyauth = require 'everyauth'
connect = require 'connect'
socketio = require 'socket.io'
express = require 'express'
http = require 'http'
#mongojs = require 'mongojs'
mongoose = require 'mongoose'
Schema = mongoose.Schema
mongooseAuth = require 'mongoose-auth'

app = express()
server = http.createServer app




UserSchema = new Schema {}
mongooseAuthConf =
        everymodule:
                everyauth:
                        User: ->
                                return User
        twitter:
                everyauth:
                        consumerKey: 'ULa9XBYdcJP7c23174WgPQ'
                        consumerSecret: 'N8D436bhbb9HFcnP0xsk9XHgxCwXFmS3M0jyrgG4Dg'
                        myHostname: 'http://smith.local:8999'
                        redirectPath: '/'
        facebook:
                everyauth:
                        appId: '483990011613446'
                        appSecret: '6049093cb268fdaf176f1c1e2e8571df'
                        myHostname: 'http://smith.local:8999'
                        redirectPath: '/'

        github:
                everyauth:
                        appId: '8ea0d317383e00fd0618'
                        appSecret: '37da922b339bd5bb5d12632ca37331ea61b7c390'
                        myHostname: 'http://smith.local:8999'
                        redirectPath: '/'
        instagram:
                everyauth:
                        appId: ''
                        appSecret: ''
                        myHostname: 'http://smith.local:8999'
                        redirectPath: '/'
        password:
                loginWith: 'email'
                everyauth:
                        #loginWith: 'email'
                        getLoginPath: '/login'
                        postLoginPath: '/login'
                        #passwordFormFieldName: 'password'
                        loginView: 'login.jade'
                        #authenticate: (login, password) ->
                        getRegisterPath: '/register'
                        postRegisterPath: '/register'
                        registerView: 'register.jade'
                        #validateRegistration: (newUserAttributes) ->
                        #registerUser: (newUserAttributes) ->
                        loginSuccessRedirect: '/'
                        registerSuccessRedirect: '/'
UserSchema.plugin mongooseAuth, mongooseAuthConf
mongoose.model 'User', UserSchema


app.configure ->
        #app.set 'view engine', 'ejs'
        #app.set 'view options', { layout: true }
        app.set 'views', "#{__dirname}/views"
        app.set 'view engine', 'jade'
        app.use express.bodyParser()
        app.use express.static("#{__dirname}/static")
        app.use express.favicon()

        app.use express.cookieParser()
        app.use express.session({ secret: 'change-me' })
        app.use mongooseAuth.middleware()
        #app.use everyauth.middleware()
        #app.use express.methodOverride()
        #app.use app.router
        #everyauth.helpExpress app

mongooseAuth.helpExpress app

app.configure 'development', ->
        app.use express.errorHandler
                dumpExceptions: true
                showStack: true

app.configure 'production', ->
        app.use express.errorHandler()

app.get '/private', (req, res) ->
        if req.session.auth and req.session.auth.loggedIn
                res.render 'private', { title: 'Protected' }
        else
                console.log 'The user is not logged in'
                res.redirect '/'


app.get '/about', (req, res) ->
        context =
                page: 'about'
                maintenance: settings.maintenance
        res.render 'index', context

class Rand
        constructor: (@seed) ->
                @multiplier = 1664525
                @modulo = 4294967296 # 2**32-1;
                @offset = 1013904223
                unless @seed? && 0 <= seed < @modulo
                        @seed = (new Date().valueOf() * new Date().getMilliseconds()) % @modulo
                return @

        seed: (seed) ->
                @seed = seed

        # return a random integer 0 <= n < @modulo
        randn: ->
             @seed = (@multiplier * @seed + @offset) % @modulo

        # return a random float 0 <= f < 1.0
        randf: ->
             this.randn() / @modulo

        # return a random int 0 <= f < n
        rand: (n) ->
                Math.floor(this.randf() * n)

        # return a random int min <= f < max
        rand2: (min, max) ->
                min + this.rand(max-min)

if not settings.maintenance
        #db = mongojs.connect settings.dburl, ["users", "lotos", "votes"]
        if mongoose.connection.readyState != 1 and mongoose.connection.readyState != 2
                console.log "Connecting to mongoose !"
                db = mongoose.connect settings.dburl
                User = mongoose.model 'User'
        models = require('./models') mongoose, db

        io = socketio.listen server

        io.on 'connection', (client) ->
                client.userId = -1 #TODO
                client.json.send { maintenance: settings.maintenance }
                #client.json.send { userId: client.userId }
                client.ip = client.manager.handshaken[client.id].address.address
                client.on 'request', (req) ->
                        client.ip = req.header 'x-real-ip' || req.headers 'x-forwarded-for' || client.ip

                client.on 'error', (err) ->
                        console.log err

                client.on 'message', (message) ->
                        sess = 'test'
                        console.log 'new Message !', message
                        if message.action
                                if message.action == 'save-vote'
                                        message.when = new Date()
                                        message.ip = client.ip
                                        delete message.action

                                        throttled = false
                                        if settings.throttle
                                                throttled = true
                                                throttled = exports.doThrottle message, client

                                        if (not throttled and client.handshaked) || not settings.throttle
                                                db.save message, (err, res) ->
                                                        if err
                                                                console.error err
                                                                client.send { error: err }
                                                        else
                                                                #client.json.send res
                                                                exports.getVotes sess, (votes, err, res) ->
                                                                        if err
                                                                                console.error err
                                                                                client.send err
                                                                        else
                                                                                io.broadcast { votes: votes }
                                        else
                                                client.send { throttled: true }

                                #if message.action == 'set-bingo'
                                if message.userId?
                                        console.log 'settings userid: #{message.userId}'
                                        client.userId = message.userId

                                if message.bingoId?
                                        console.log 'setting bingo'
                                        client.bingoId = message.bingoId

                                if message.action == 'get-bingo'
                                        console.log "getting bingo: #{client.bingoId}, #{client.userId}"
                                        exports.getBingo client.userId, client.bingoId, (bingo, err, res) ->
                                                if err
                                                        console.log err
                                                        client.send err
                                                else
                                                        client.json.send { bingo: bingo }


                                if message.action == 'get-checks'
                                        console.log 'Getting checks'
                                        exports.getChecks client.bingoId, (checks, err, res) ->
                                                if err
                                                        console.error err
                                                        client.send err
                                                else
                                                        client.json.send { checks: checks }

                client.on 'disconnect', ->
                        console.log 'client disconnected'

console.log 'Server side socket started'

exports.shuffle = (array, seed) ->
        rand = new Rand seed
        for i in [0...array.length]
                j = parseInt rand.randf() * i
                x = array[i]
                array[i] = array[j]
                array[j] = x
        return array

exports.getBingo = (userId, bingoId, callback, res) ->
        models.Bingo.findOne { hash: bingoId }, (err, bingo) ->
                ret = {}
                ret['_id'] = bingo._id
                ret['title'] = bingo.title
                ret['hash'] = bingo.hash

                len = bingo.opts.length
                sort = []
                for i in [0...len]
                        sort.push i
                if userId
                        exports.shuffle sort, userId / 100000
                        console.log sort
                ret['opts'] = []
                for i in [0...len]
                        ret['opts'].push
                                #i: i
                                id: sort[i]
                                value: bingo.opts[sort[i]]
                console.log ret['opts']
                console.log 'getBingo', bingo
                callback ret, err, res

exports.getPlayers = (bingoId, callback, res) ->
        players =
                0:
                        name: "Manfred"
                1:
                        name: "Solvik"
                5:
                        name: "Charles"
        err = null
        callback players, err, res

exports.getChecks = (bingoId, callback, res) ->
        checks =
                0: [1, 2, 5, 6],
                1: [2, 4, 5, 7],
                5: [5, 1, 4, 5]
        err = null
        callback checks, err, res

exports.doThrottle = (message, client) ->
        throttled = true
        throttle[client.sessionId] = throttle[client.sessionId] || 0
        throttle[client.sessionId]++

        if throttle[client.sessionId] <= throttleVotes
                throttled = false

        if Object.keys(throttle).length > 10000
                first = null
                for first in throttle
                        break
                delete throttle[first]


app.get '/moul', (req, res) ->
        #models.Bingo            = mongoose.model 'Bingo', Bingo
        #models.User             = mongoose.model 'User', User
        #models.BingoOption      = mongoose.model 'BingoOption', BingoOption
        #models.Vote             = mongoose.model 'Vote', Vote

        title = 'test997'
        models.Bingo.findOne { title: title }, (err, bingo) ->
                if err
                        console.log err
                if not bingo? or not bingo
                        bingo = new models.Bingo()
                        bingo.title = title
                        bingo.hash = title

                for i in [0...16]
                        bingo.opts[i] = 'test2' + i

                bingo.save (err) ->
                        console.log bingo
                        if err
                                console.log err
                                res.send err
                        else
                                res.send 'OK ' + new Date()

app.get '/', (req, res) ->
        context =
                page: 'default'
                maintenance: settings.maintenance
                title: 'Default'
                everyauth: everyauth
        console.log mongooseAuth
        if req.query?
                if req.query.bingo?
                        context.bingo = req.query.bingo
                if req.query.userId?
                        context.userId = req.query.userId
        res.render 'index', context

server.listen settings.port
console.log "Server is listening on port %d in %s mode", server.address().port, app.settings.env
exports.app = app
