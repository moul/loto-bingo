db = require '../../db'

exports.before = (req, res, next) ->
        id = req.params.bingo_id
        if not id
                return do next
        process.nextTick ->
                req.bingo = db.bingos[id]
                if not req.bingo
                        return next new Error 'User not found'
                do next

exports.list = (req, res, next) ->
        res.message 'TODO'
        res.render 'list', { bingos: db.bingos }

exports.edit = (req, res, next) ->
        res.message 'EDIT'
        res.render 'edit', { bingo: req.bingo }

exports.show = (req, res, next) ->
        res.message 'SHOW', 'error'
        res.render 'show', { bingo: req.bingo }
        #console.log '-------------------------'
        #console.dir req.bingo
        #console.log '-------------------------'
        #res.render 'index', { title: req.bingo.title, content: 'test' }

exports.update = (req, res, next) ->
        #body = req.body
        #req.user.name = body.user.name
        #res.message 'Information updated !'
        #res.redirect "/user/#{req.user.id}"
        res.message 'TODO'
