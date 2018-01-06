module Inkwell
  module Errors
    class CannotReblog < StandardError
      def initialize(object)
        @object = object
      end

      def message
        # move to <<~ when ruby supported version starts 2.3 or upper version
        <<-MESSAGE
#{@object.class} cannot use reblog feature.
include Inkwell::CanReblog to #{@object.class} if this object should can reblog.
        MESSAGE
      end
    end
  end
end
