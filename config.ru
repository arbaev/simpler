# frozen_string_literal: true

require_relative 'config/environment'
require_relative 'lib/middleware/racklogger'

use RackLogger
run Simpler.application
