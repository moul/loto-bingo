exports.index = (req, res) ->
        res.message 'salut !', 'warning'
        res.render 'index', { title: 'Home' }
        #res.redirect '/login'

exports.login = require './login'
