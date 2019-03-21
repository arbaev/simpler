require_relative 'view'

module Simpler
  class Controller

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
      else
        set_headers(:html)
        write_response(render_body)
      end

      @response.finish
    end

    private

    def status(number)
      @response.status = number
    end

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase
    end

    def set_headers(type = :html)
      case type
      when :plain
        @response['Content-Type'] = 'text/plain'
      else
        @response['Content-Type'] = 'text/html'
      end
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

  end
end
