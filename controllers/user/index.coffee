db = require '../../db'

exports.before = (req, res, next) ->
        id = req.params.user_id
        if not id
                return do next
        process.nextTick ->
                req.user = db.users[id]
                if not req.user
                        return next new Error 'User not found'
                do next

exports.list = (req, res, next) ->
        res.render 'list', { users: db.users }

exports.edit = (req, res, next) ->
        res.render 'edit', { user: req.user }

exports.show = (req, res, next) ->
        res.render 'show', { user: req.user }

exports.update = (req, res, next) ->
        body = req.body
        req.user.name = body.user.name
        res.message 'Information updated !'
        res.redirect "/user/#{req.user.id}"

exports.locals =
        menus:
                left:
                        '/users':
                                title: 'Users'
                navbar:
                        '/users':
                                title: 'Users'
