module Inkwell
  module Errors
    class CannotFavorite < StandardError
      def initialize(object)
        @object = object
      end

      def message
        # move to <<~ when ruby supported version starts 2.3 or upper version
        <<-MESSAGE
#{@object.class} cannot use favorite feature.
include Inkwell::CanFavorite to #{@object.class} if this object should can favorite.
        MESSAGE
      end
    end
  end
end
