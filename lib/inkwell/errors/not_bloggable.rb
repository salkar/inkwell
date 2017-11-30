module Inkwell
  module Errors
    class NotBloggable < StandardError
      def initialize(object)
        @object = object
      end

      def message
        # move to <<~ when ruby supported version starts 2.3 or upper version
        <<-MESSAGE
#{@object.class} cannot be added to blog.
include Inkwell::CanBeBlogged to #{@object.class} if this object should be added to blog.
        MESSAGE
      end
    end
  end
end
