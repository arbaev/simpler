require_relative 'config/environment'
require_relative 'lib/middleware/racklogger'

use RackLogger
run Simpler.application
