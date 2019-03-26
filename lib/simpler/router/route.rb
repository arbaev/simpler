module Simpler
  class Router
    class Route

      attr_reader :controller, :action

      def initialize(method, path, controller, action)
        @method = method
        @path = path
        @controller = controller
        @action = action
      end

      def match?(method, path)
        @method == method && path_match?(path)
      end

      def recognize_params(path)
        source_path_arr = split_path(path)
        route_path_arr = split_path(@path)

        source_path_arr.reduce({}) do |params, el|
          route_el = route_path_arr[source_path_arr.index(el)]
          return nil if route_el.nil?

          if route_el[0] == ':'
            params[convert_param_to_sym(route_el)] = el
          elsif route_el != el
            return nil
          end

          params
        end
      end

      private

      def path_match?(path)
        !!recognize_params(path)
      end

      def split_path(path)
        path[1..-1].split('/')
      end

      def convert_param_to_sym(param)
        param[1..-1].to_sym
      end

    end
  end
end
