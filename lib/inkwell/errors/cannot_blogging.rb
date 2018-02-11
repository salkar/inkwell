# frozen_string_literal: true

module Inkwell
  module Errors
    class CannotBlogging < StandardError
      def initialize(object)
        @object = object
      end

      def message
        # move to <<~ when ruby supported version starts 2.3 or upper version
        <<-MESSAGE
#{@object.class} cannot use blogging feature.
include Inkwell::CanBlogging to #{@object.class} if this object should can blogging.
        MESSAGE
      end
    end
  end
end
