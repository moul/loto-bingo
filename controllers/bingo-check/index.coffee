db = require '../../db'

exports.name = 'check'
exports.prefix = '/bingo/:bingo_id'

exports.before = (req, res, next) ->
        id = req.params.check_id
        if not id
                return do next
        process.nextTick ->
                req.check = id
                return do next

exports.show = (req, res, next) ->
        res.json
                status: 'ok'
                bingo: req.bingo.id
                check: req.check
                text: req.bingo.cases[req.check]
                user: req.user