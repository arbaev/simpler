require 'logger'

class RackLogger
  LOG_DIRNAME = "log".freeze
  LOG_FILENAME = "app.log".freeze

  def initialize(app)
    @app = app
    @logger = logger
  end

  def call(env)
    status, headers, body = @app.call(env)

    data = {
        status: status,
        headers: headers,
        verb: env['REQUEST_METHOD'],
        uri: env['REQUEST_URI'],
        controller: env['simpler.controller'],
        action: env['simpler.action'],
        params: env['simpler.params'],
        template: env['simpler.template'],
    }.freeze

    log_write(data)

    [status, headers, body]
  end

  private

  def logger
    file = "#{Simpler.root}/#{LOG_DIRNAME}/#{LOG_FILENAME}"
    logger = Logger.new(file, level: :info)
    logger.formatter = proc do |_severity, datetime, _progname, msg|
      "#{datetime}: #{msg}\n"
    end

    logger
  end

  def log_write(data)
    @logger.info(output(data))
    @logger.close
  end

  def output(data)
    <<~LOG_RECORD
      \n#{show_request(data)}
      #{show_handler(data)}
      #{show_params(data)}
      #{show_response(data)}
    LOG_RECORD
  end

  def show_request(data)
    "Request: #{data[:verb]} #{data[:uri]}"
  end

  def show_handler(data)
    handler = data[:controller].nil? ? "N/A" : "#{data[:controller].class}##{data[:action]}"
    "Handler: #{handler}"
  end

  def show_params(data)
    parameters = data[:params].nil? || data[:params].empty? ? "none" : data[:params]
    "Parameters: #{parameters}"
  end

  def show_response(data)
    show_status = "#{data[:status]} #{Rack::Utils::HTTP_STATUS_CODES[data[:status]]}"
    show_header = "[#{data[:headers]['Content-Type']}]"
    "Response: #{show_status}, #{show_header} #{show_template(data)}"
  end

  def show_template(data)
    return '' if data[:controller].nil?
    data[:template]&.keys&.first || "#{data[:action]}.html.erb"
  end
end
