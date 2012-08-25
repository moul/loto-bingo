exports.index = (req, res) ->
        res.render 'index', { title: 'Loto-Bingo' }

exports.login = require './login'
