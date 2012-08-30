db = require '../../db'

#exports.before = (req, res, next) ->
#        id = req.params.user_id
#        if not id
#                return do next
#        process.nextTick ->
#                req.user = db.users[id]
#                if not req.user
#                        return next new Error 'User not found'
#                do next

exports.list = (req, res, next) ->
        res.message 'TODO'
        res.render 'list', { bingos: db.bingos }

exports.edit = (req, res, next) ->
        res.message 'EDIT'
        res.render 'edit', { bingo: req.bingo }

exports.show = (req, res, next) ->
        res.message 'SHOW'
        #res.render 'show', { bingo: req.bingo }
        res.render 'index', { title: 'salut', content: 'test' }

exports.update = (req, res, next) ->
        #body = req.body
        #req.user.name = body.user.name
        #res.message 'Information updated !'
        #res.redirect "/user/#{req.user.id}"
        res.message 'TODO'

