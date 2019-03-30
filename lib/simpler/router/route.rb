# frozen_string_literal: true

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
        @method == method && match_path?(path)
      end

      def match_path?(path)
        path_arr = split_path(path)
        pattern = convert_path_to_pattern(@path)

        return false unless path_arr.size == pattern.size

        pattern.zip(path_arr).all? do |pattern_part, path_part|
          pattern_part.is_a?(Symbol) || pattern_part == path_part
        end
      end

      def path_params(path)
        path_arr = split_path(path)
        pattern = convert_path_to_pattern(@path)

        pattern.each.with_index.with_object({}) do |(el, i), result|
          result[el] = path_arr[i] if el.is_a?(Symbol)
        end
      end

      private

      def convert_path_to_pattern(path)
        split_path(path).map { |el| el[0] == ':' ? convert_param_to_sym(el) : el }
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
