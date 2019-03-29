# frozen_string_literal: true

require_relative 'view'

module Simpler
  class Controller
    CONTENT_TYPES = { plain: 'text/plain', path: 'text/html' }.freeze

    attr_reader :name, :request, :response

    def initialize(request)
      @name = extract_name
      @request = request
      @response = Rack::Response.new
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

    def set_content_type_header
      type = @request.env['simpler.template'].keys.first
      @response['Content-Type'] = CONTENT_TYPES[type]
    end

    def write_response(body)
      @response.write(body)
    end

    def render_response(template)
      render(template)
      set_content_type_header
      View.new(@request.env).render(binding)
    end

    def render(template)
      template = if template.is_a?(String)
                   { path: template }
                 elsif template.nil?
                   { path: [name, @request.env['simpler.action']].join('/') }
                 else
                   template
                 end

      @request.env['simpler.template'] = template
    end

    def params
      @request.env['simpler.params']
    end

    def headers
      @response.header
    end

  end
end
