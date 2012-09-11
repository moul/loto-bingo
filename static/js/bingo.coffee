(($, window, console) ->

        debug = (message, args) ->
                $('.socket-status').html message
                if args
                        console.log message, args
                else
                        console.log message

        defaults =
                canCheck: true
                checksLeft: 3
                checkTime: 20
                canvasX: 800
                canvasY: 480
                countColor: '#CCCCCC'
                container: false

        class Bingo
                constructor: (options) ->
                        @connected = false
                        @options = $.extend {}, defaults, options
                        @socket = null

                        @started = true
                        @isThrottled = false

                        @keepConnection()

                        if not @options.container
                                @options.container = $('body')

                        return @

                keepConnection: ->
                        that = @

                        @socket = io.connect '', @options

                        @socket.on 'connecting', ->
                                debug 'connecting'

                        @socket.on 'connect', ->
                                that.connected = true
                                debug 'connect'
                                that.start()

                        @socket.on 'connect_failed', ->
                                debug 'connect failed'

                        @socket.on 'disconnect', ->
                                that.connected = false
                                debug 'disconnect'
                                setTimeout (-> that.keepConnection()), 1000

                        @socket.on 'message', (message) ->
                                debug 'new message', message
                                that.handleMessage message


                handleMessage: (message) ->
                        if message.throttled?
                                debug '.throttled?'
                                $('#message').html 'You have been throttled, try again later.'
                                @doneLoading()
                                debug '.isThrottled?'
                        if message.bingo?
                                @bingo = message.bingo
                                @displayBingo()
                                debug '.bingo?'
                        if message.checks?
                                debug '.checks?'
                                oldChecks = message.checks
                                @checks = message.checks
                                @displayChecks()
                        if message.userId?
                                debug '.userId?'
                                @userId = message.userId
                        if message.maintenance?
                                debug '.maintenance?'
                                if message.maintenance
                                        $('#message').html 'Website is under maintenance'
                                else
                                        $('#message').html 'Website is running fine'
                        if message.isThrottled?
                                this.isThrottled = message.isThrottled

                start: ->
                        that = @
                        debug 'start'
                        @isLoading()
                        if @isThrottled
                                @displayCheckCount()
                        that.setUserid ->
                                that.setBingo ->
                                        that.getBingo ->
                                                #console.log 'getBingo callback'
                                                that.getChecks ->
                                                        #console.log 'getChecks callback'

                displayBingo: (callback) ->
                        that = @
                        length = @bingo.opts.length
                        size = Math.sqrt(length)
                        console.log size
                        if not @table?
                                @table = $('<table></table>')
                                @table.addClass 'bingo'
                                for y in [0...size]
                                        rows = $('<tr></tr>')
                                        for x in [0...size]
                                                i = y * size + x
                                                opt = @bingo.opts[i]

                                                link = $('<a></a>')
                                                link.html opt.value
                                                link.attr 'data-checkid', opt.id
                                                #link.attr 'data-checkid', y * size + x

                                                row = $('<td></td>')
                                                link.click (e) ->
                                                        link = $(this)
                                                        e.preventDefault()
                                                        if link.hasClass 'active'
                                                                return
                                                        that.socket.json.send { action: 'check', checkId: $(this).attr 'data-checkid' }, ->
                                                                console.log link
                                                                link.addClass 'active'
                                                row.append link
                                                rows.append row
                                        @table.append rows
                                @options.container.append @table
                        console.log '@checks', @checks
                        if @checks?
                                @displayChecks(callback)
                        else if callback?
                                callback()

                displayChecks: (callback) ->
                        if @table? and @userId? and @userId and @checks? and @checks[@userId]
                                for check in @checks[@userId]
                                        @table.find("[data-checkid=#{check}]").addClass 'active'
                        else
                                console.log 'no checks for current user'
                        if callback?
                                callback()
                        @doneLoading()

                setBingo: (callback) ->
                        #debug 'setting bingo'
                        @socket.json.send { action: 'set-bingo', bingoId: @options.bingoId }, callback

                setUserid: (callback) ->
                        @userId = @options.userId
                        debug "setting userid: #{@options.userId}"
                        @socket.json.send { action: 'set-userid', userId: @options.userId }, callback

                getBingo: (callback) ->
                        #debug 'getting bingo'
                        @socket.json.send { action: 'get-bingo' }, callback

                getChecks: (callback) ->
                        #debug 'getting checks'
                        @socket.json.send { action: 'get-checks' }, callback

                isLoading: ->
                        @loading = true
                        $('#loading').show()

                doneLoading: ->
                        @loading = false
                        $('#loading').hide()

        main = ->
                bingo = null
                if bingoId?
                        options =
                                bingoId: bingoId
                                container: $('#main')
                        if userId?
                                options.userId = userId
                        bingo = new Bingo options
                return bingo

        $(document).ready main

)(jQuery, window, console)
