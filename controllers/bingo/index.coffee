db = require '../../db'
utils = require '../../utils'
greatest_factor = utils.greatest_factor


exports.before = (req, res, next) ->
        id = req.params.bingo_id
        if not id
                return do next
        process.nextTick ->
                req.bingo = db.bingos[id]
                if not req.bingo
                        return next new Error 'User not found'

                if req.bingo.entries == 'auto'
                        req.bingo.entries = req.bingo.cases.length
                a = greatest_factor req.bingo.entries
                b = req.bingo.entries / a
                req.bingo.height = Math.max a, b
                req.bingo.width = Math.min a, b
                req.bingo.span = Math.floor(12 / req.bingo.width)

                do next

exports.list = (req, res, next) ->
        res.message 'TODO'
        res.render 'list', { bingos: db.bingos }

exports.edit = (req, res, next) ->
        res.message 'EDIT'
        res.render 'edit', { bingo: req.bingo }

exports.show = (req, res, next) ->
        res.message 'SHOW'
        res.render 'show', { bingo: req.bingo }

exports.update = (req, res, next) ->
        body = req.body
        req.bingo.title = body.bingo.title
        req.bingo.cases = body.bingo.cases.split("\n")
        res.message 'Information updated !'
        res.redirect "/bingo/#{req.bingo.id}"

exports.locals =
        menus:
                left:
                        '/bingos':
                                title: 'Bingos'
                navbar:
                        '/bingos':
                                title: 'Bingos'

if db.bingos
        exports.locals.menus.left['/bingos'].childrens = {}
        for id, bingo of db.bingos
                exports.locals.menus.left['/bingos'].childrens["/bingo/#{bingo.id}"] =
                        title: bingo.title
