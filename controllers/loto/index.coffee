db = require '../../db'

exports.before = (req, res, next) ->
    id = req.params.loto_id
    return do next if not id
    process.nextTick ->
        if db.lotos[id]?
            req.loto = db.lotos[id]
            return do next
        return do next

exports.list = (req, res) ->
    lotos = {}
    res.render 'list', { lotos: lotos }

exports.show = (req, res) ->
    loto = {}
    #console.log req.loto
    user = {}
    questions = ['test', 'test2']
    res.render 'show',
        loto: req.loto
        user: user
        questions: questions
