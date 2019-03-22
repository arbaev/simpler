module Simpler
  class Router
    class Route

      attr_reader :controller, :action, :param

      def initialize(method, path, controller, action)
        @method = method
        @path, text_id = path
        @controller = controller
        @action = action
        @param = nil
        @id = text_id&.to_sym
      end

      def match?(method, path)
        mpath, value = path

        if value.nil?
          @method == method && mpath.match(@path)
        elsif value && @id
          @param = {@id => value.to_i}
          @method == method && mpath.match(@path) && @id
        end
      end

    end
  end
end
