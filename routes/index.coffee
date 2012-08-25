exports.index = (req, res) ->
        res.render 'index', { title: 'Index' }

exports.login = require './login'
