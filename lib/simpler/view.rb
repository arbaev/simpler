# frozen_string_literal: true

require 'erb'

module Simpler
  class View
    VIEW_BASE_PATH = 'app/views'

    def initialize(env)
      @env = env
    end

    def render(binding)
      type, body = template.first
      send("render_#{type}", body, binding)
    end

    private

    def render_plain(body, _binding)
      body
    end

    def render_path(path, binding)
      template_path = Simpler.root.join(VIEW_BASE_PATH, "#{path}.html.erb")
      template_file = File.read(template_path)
      ERB.new(template_file).result(binding)
    end

    def template
      @env['simpler.template']
    end

  end
end
