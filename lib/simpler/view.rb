require 'erb'

module Simpler
  class View

    VIEW_BASE_PATH = 'app/views'.freeze

    def initialize(env)
      @env = env
    end

    def render(binding)
      case template.keys.first
      when :plain
        render_plain
      # when :json
      #   render_json
      when nil
        template_file = File.read(template_path)
        ERB.new(template_file).result(binding)
      else
        raise ArgumentError, 'Unknown template format'
      end
    end

    private

    def render_plain
      template.values.first
    end

    def controller
      @env['simpler.controller']
    end

    def action
      @env['simpler.action']
    end

    def template
      @env['simpler.template']
    end

    def template_path
      path = [controller.name, action].join('/')

      Simpler.root.join(VIEW_BASE_PATH, "#{path}.html.erb")
    end

  end
end
