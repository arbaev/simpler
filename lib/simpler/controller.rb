require_relative 'view'

module Simpler
  class Controller
    CONTENT_TYPES = { plain: 'text/plain', html: 'text/html' }.freeze

    attr_reader :name, :request, :response

    def initialize(env)
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
    end

    def make_response(action)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action

      send(action)
      template = @request.env['simpler.template']

      if template.is_a?(Hash) && template.has_key?(:plain)
        set_headers(:plain)
        write_response(template[:plain])
      elsif controller_found?
        set_headers(:html)
        write_response(render_body)
      end

      @response.finish
    end

    private

    def controller_found?
      !@request.env.has_key?('not_found')
    end

    def not_found
      status 404
      set_headers(:plain)
      write_response("URL not found")
    end

    def status(number)
      @response.status = number
    end

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase
    end

    def set_headers(type = :html)
      @response['Content-Type'] = CONTENT_TYPES[type]
    end

    def write_response(body)
      @response.write(body)
    end

    def render_body
      View.new(@request.env).render(binding)
    end

    def params
      @request.params
    end

    def render(template)
      @request.env['simpler.template'] = template
    end

    def headers
      @response.header
    end
  end
end
