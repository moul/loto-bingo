// Generated by CoffeeScript 1.3.3
(function() {

  (function($, window, console) {
    var Bingo, debug, defaults, main;
    debug = function(message, args) {
      $('.socket-status').html(message);
      if (args) {
        return console.log(message, args);
      } else {
        return console.log(message);
      }
    };
    defaults = {
      canCheck: true,
      checksLeft: 3,
      checkTime: 20,
      canvasX: 800,
      canvasY: 480,
      countColor: '#CCCCCC',
      container: false
    };
    Bingo = (function() {

      function Bingo(options) {
        this.connected = false;
        this.options = $.extend({}, defaults, options);
        this.socket = null;
        this.started = true;
        this.isThrottled = false;
        this.keepConnection();
        if (!this.options.container) {
          this.options.container = $('body');
        }
        return this;
      }

      Bingo.prototype.keepConnection = function() {
        var that;
        that = this;
        this.socket = io.connect('', this.options);
        this.socket.on('connecting', function() {
          return debug('connecting');
        });
        this.socket.on('connect', function() {
          that.connected = true;
          debug('connect');
          return that.start();
        });
        this.socket.on('connect_failed', function() {
          return debug('connect failed');
        });
        this.socket.on('disconnect', function() {
          that.connected = false;
          debug('disconnect');
          return setTimeout((function() {
            return that.keepConnection();
          }), 1000);
        });
        return this.socket.on('message', function(message) {
          debug('new message', message);
          return that.handleMessage(message);
        });
      };

      Bingo.prototype.handleMessage = function(message) {
        var oldChecks;
        if (message.throttled != null) {
          debug('.throttled?');
          $('#message').html('You have been throttled, try again later.');
          this.doneLoading();
          debug('.isThrottled?');
        }
        if (message.bingo != null) {
          this.bingo = message.bingo;
          this.displayBingo();
          debug('.bingo?');
        }
        if (message.checks != null) {
          debug('.checks?');
          oldChecks = message.checks;
          this.checks = message.checks;
          this.displayChecks();
        }
        if (message.userId != null) {
          debug('.userId?');
          this.userId = message.userId;
        }
        if (message.maintenance != null) {
          debug('.maintenance?');
          if (message.maintenance) {
            $('#message').html('Website is under maintenance');
          } else {
            $('#message').html('Website is running fine');
          }
        }
        if (message.isThrottled != null) {
          return this.isThrottled = message.isThrottled;
        }
      };

      Bingo.prototype.start = function() {
        var that;
        that = this;
        debug('start');
        this.isLoading();
        if (this.isThrottled) {
          this.displayCheckCount();
        }
        return that.setUserid(function() {
          return that.setBingo(function() {
            return that.getBingo(function() {
              return that.getChecks(function() {});
            });
          });
        });
      };

      Bingo.prototype.displayBingo = function(callback) {
        var i, length, link, opt, row, rows, size, that, x, y, _i, _j;
        that = this;
        length = this.bingo.opts.length;
        size = Math.sqrt(length);
        console.log(size);
        if (!(this.table != null)) {
          this.table = $('<table></table>');
          this.table.addClass('bingo');
          for (y = _i = 0; 0 <= size ? _i < size : _i > size; y = 0 <= size ? ++_i : --_i) {
            rows = $('<tr></tr>');
            for (x = _j = 0; 0 <= size ? _j < size : _j > size; x = 0 <= size ? ++_j : --_j) {
              i = y * size + x;
              opt = this.bingo.opts[i];
              link = $('<a></a>');
              link.html(opt.value);
              link.attr('data-checkid', opt.id);
              row = $('<td></td>');
              link.click(function(e) {
                link = $(this);
                e.preventDefault();
                if (link.hasClass('active')) {
                  return;
                }
                return that.socket.json.send({
                  action: 'check',
                  checkId: $(this).attr('data-checkid')
                }, function() {
                  console.log(link);
                  return link.addClass('active');
                });
              });
              row.append(link);
              rows.append(row);
            }
            this.table.append(rows);
          }
          this.options.container.append(this.table);
        }
        console.log('@checks', this.checks);
        if (this.checks != null) {
          return this.displayChecks(callback);
        } else if (callback != null) {
          return callback();
        }
      };

      Bingo.prototype.displayChecks = function(callback) {
        var check, _i, _len, _ref;
        if ((this.table != null) && (this.userId != null) && this.userId && (this.checks != null) && this.checks[this.userId]) {
          _ref = this.checks[this.userId];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            check = _ref[_i];
            this.table.find("[data-checkid=" + check + "]").addClass('active');
          }
        } else {
          console.log('no checks for current user');
        }
        if (callback != null) {
          callback();
        }
        return this.doneLoading();
      };

      Bingo.prototype.setBingo = function(callback) {
        return this.socket.json.send({
          action: 'set-bingo',
          bingoId: this.options.bingoId
        }, callback);
      };

      Bingo.prototype.setUserid = function(callback) {
        this.userId = this.options.userId;
        debug("setting userid: " + this.options.userId);
        return this.socket.json.send({
          action: 'set-userid',
          userId: this.options.userId
        }, callback);
      };

      Bingo.prototype.getBingo = function(callback) {
        return this.socket.json.send({
          action: 'get-bingo'
        }, callback);
      };

      Bingo.prototype.getChecks = function(callback) {
        return this.socket.json.send({
          action: 'get-checks'
        }, callback);
      };

      Bingo.prototype.isLoading = function() {
        this.loading = true;
        return $('#loading').show();
      };

      Bingo.prototype.doneLoading = function() {
        this.loading = false;
        return $('#loading').hide();
      };

      return Bingo;

    })();
    main = function() {
      var bingo, options;
      bingo = null;
      if (typeof bingoId !== "undefined" && bingoId !== null) {
        options = {
          bingoId: bingoId,
          container: $('#main')
        };
        if (typeof userId !== "undefined" && userId !== null) {
          options.userId = userId;
        }
        bingo = new Bingo(options);
      }
      return bingo;
    };
    return $(document).ready(main);
  })(jQuery, window, console);

}).call(this);
