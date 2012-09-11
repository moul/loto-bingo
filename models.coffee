module.exports = (mongoose, db) ->
        models = {}

        User = new mongoose.Schema
                login     : String

        BingoOption = new mongoose.Schema
                title     : String
                #bingo     : Bingo

        Bingo = new mongoose.Schema
                title     : String
                opts      : [ String ]
                #players   : [ User ]

        Vote = new mongoose.Schema
                user      : [ User ]
                bingo     : [ Bingo ]
                option    : [ BingoOption ]

        #models.BingoOption      = db.model 'BingoOption', BingoOption
        models.Bingo            = db.model 'Bingo', Bingo
        #models.User             = db.model 'User', User
        #models.Vote             = db.model 'Vote', Vote

        return models
