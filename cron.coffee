# Loading dependencies
kickstart2 = require '../kickstart2'

# Loading and setting config
kickstart2.config = require './config'

# Running cron
kickstart2.runCron()
