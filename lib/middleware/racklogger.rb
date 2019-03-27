class RackLogger
  LOG_DIRNAME = "log".freeze
  LOG_FILENAME = "app.log".freeze

  def initialize(app)
    @app = app
    Dir.mkdir("#{Simpler.root}/#{LOG_DIRNAME}") unless Dir.exist?("#{Simpler.root}/#{LOG_DIRNAME}")
  end

  def call(env)
    start = Time.now
    status, headers, body = @app.call(env)

    @data = {
        start: start,
        status: status,
        headers: headers,
        verb: env['REQUEST_METHOD'],
        uri: env['REQUEST_URI'],
        controller: env['simpler.controller'],
        action: env['simpler.action'],
        params: env['simpler.params'],
        template: env['simpler.template'],
        stop: Time.now
    }

    File.open("#{Simpler.root}/#{LOG_DIRNAME}/#{LOG_FILENAME}", "a+") {|f| f.write(output) }

    [status, headers, body]
  end

  private

  def output
    "#{show_divider}\n#{show_time}\n#{show_request}\n#{show_handler}\n#{show_params}\n#{show_response}\n"
  end

  def show_time
    elapsed_time = @data[:stop] - @data[:start]
    "#{@data[:start].strftime "%Y-%m-%d %H:%M:%S"}, response time: #{to_ms(elapsed_time)}ms"
  end

  def to_ms(seconds)
    (seconds * 1000.0).round(5)
  end

  def show_request
    "Request: #{@data[:verb]} #{@data[:uri]}"
  end

  def show_handler
    handler = @data[:controller].nil? ? "N/A" : "#{@data[:controller].class}##{@data[:action]}"
    "Handler: #{handler}"
  end

  def show_params
    parameters = @data[:params].nil? || @data[:params].empty? ? "none" : @data[:params]
    "Parameters: #{parameters}"
  end

  def show_response
    show_status = "#{@data[:status]} #{Rack::Utils::HTTP_STATUS_CODES[@data[:status]]}"
    show_header = "[#{@data[:headers]['Content-Type']}]"
    "Response: #{show_status}, #{show_header} #{show_template}"
  end

  def show_template
    return '' if @data[:controller].nil?
    @data[:template]&.keys&.first || "#{@data[:action]}.html.erb"
  end

  def show_divider
    '-=' * 30
  end
end
