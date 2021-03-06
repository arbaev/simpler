# frozen_string_literal: true

require 'yaml'
require 'singleton'
require 'sequel'
require_relative 'router'
require_relative 'controller'

module Simpler
  class Application

    include Singleton

    attr_reader :db

    def initialize
      @router = Router.new
      @db = nil
    end

    def bootstrap!
      setup_database
      require_app
      require_routes
    end

    def routes(&block)
      @router.instance_eval(&block)
    end

    def call(env)
      @request = Rack::Request.new(env)
      route = @router.route_for(@request)
      env['simpler.params'] = @request.params
      return not_found if route.nil?

      controller = route.controller.new(@request)
      action = route.action
      env['simpler.params'] = collect_params(route, @request)
      make_response(controller, action)
    end

    private

    def collect_params(route, request)
      request.params.merge(route.path_params(request.path))
    end

    def not_found
      [404, { 'Content-Type' => 'text/plain' }, ["URL not found\n"]]
    end

    def require_app
      Dir["#{Simpler.root}/app/**/*.rb"].each { |file| require file }
    end

    def require_routes
      require Simpler.root.join('config/routes')
    end

    def setup_database
      database_config = YAML.load_file(Simpler.root.join('config/database.yml'))
      database_config['database'] = Simpler.root.join(database_config['database'])
      @db = Sequel.connect(database_config)
    end

    def make_response(controller, action)
      controller.make_response(action)
    end

  end
end
