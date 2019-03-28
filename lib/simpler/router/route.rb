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

        return false unless size_eql?(path_arr, pattern)

        pattern.each.with_index do |el, i|
          unless el.is_a?(Symbol)
            return false if el != path_arr[i]
          end
        end

        true
      end

      def path_params(path)
        path_arr = split_path(path)
        pattern = convert_path_to_pattern(@path)

        result = pattern.map.with_index do |el, i|
          el.is_a?(Symbol) ? [el, path_arr[i]] : next
        end

        result.compact.to_h
      end

      private

      def convert_path_to_pattern(path)
        split_path(path).map { |el| el[0] == ':' ? convert_param_to_sym(el) : el }
      end

      def size_eql?(path1, path2)
        path1.size == path2.size
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
