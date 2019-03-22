module Simpler
  class Router
    class Route

      attr_reader :controller, :action

      def initialize(method, path, controller, action)
        @method = method
        @path, @id = split_path(path)
        @controller = controller
        @action = action
      end

      def match?(method, path)
        mpath, mparam = split_path(path)

        if mparam.nil?
          @method == method && mpath.match(@path)
        else
          @method == method && mpath.match(@path) && @id
        end
      end

      private

      def split_path(path)
        path.split('/').reject(&:empty?)
      end
    end
  end
end
