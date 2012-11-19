exports.list = (req, res) ->
    lotos = {}
    res.render 'list', lotos

exports.show = (req, res) ->
    loto = {}
    res.render 'show', loto
