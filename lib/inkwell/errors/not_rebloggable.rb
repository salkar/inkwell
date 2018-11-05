# frozen_string_literal: true

module Inkwell
  module Errors
    class NotRebloggable < StandardError
      def initialize(object)
        @object = object
      end

      def message
        # move to <<~ when ruby supported version starts 2.3 or upper version
        <<-MESSAGE
#{@object.class} cannot be reblogged.
include Inkwell::CanBeReblogged to #{@object.class} if this object should be reblogged.
        MESSAGE
      end
    end
  end
end
