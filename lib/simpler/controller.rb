require_relative 'view'

module Simpler
  class Controller
    CONTENT_TYPES = { plain: 'text/plain', html: 'text/html' }.freeze

    attr_reader :name, :request, :response

    def initialize(env)
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
      @request.env['simpler.template'] = {}
    end

    def make_response(action)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action

      send(action)

      template = @request.env['simpler.template']
      write_response(render_response(template))

      @response.finish
    end

    private

    def status(code)
      @response.status = code
    end

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase
    end

    def set_content_type_header(type)
      type ||= :html
      @response['Content-Type'] = CONTENT_TYPES[type] || 'text/unknown'
    end

    def write_response(body)
      @response.write(body)
    end

    def render_response(template)
      set_content_type_header(template.keys.first)
      render(template)
      View.new(@request.env).render(binding)

    rescue ArgumentError => e
      puts e.message
    end

    def params
      @request.env['simpler.params']
    end

    def render(template)
      @request.env['simpler.template'] = template
    end

    def headers
      @response.header
    end
  end
end
