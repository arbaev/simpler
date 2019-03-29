require 'erb'

module Simpler
  class View

    VIEW_BASE_PATH = 'app/views'.freeze

    def initialize(env)
      @env = env
    end

    def render(binding)
      if template.is_a?(Hash)
        type, body = template.first
        send("render_#{type}", body)
      else
        render_template(binding)
      end
    end

    private

    def render_plain(body)
      body
    end

    def render_template(binding)
      template_file = File.read(template_path)
      ERB.new(template_file).result(binding)
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
      path = template || [controller.name, action].join('/')

      Simpler.root.join(VIEW_BASE_PATH, "#{path}.html.erb")
    end

  end
end
