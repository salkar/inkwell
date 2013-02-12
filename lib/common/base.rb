module Inkwell
  module Common
    def get_item_type(obj)
      post_class = Object.const_get ::Inkwell::Engine::config.post_table.to_s.singularize.capitalize
      case obj
        when ::Inkwell::Comment
          result = ::Inkwell::Constants::ItemTypes::COMMENT
        when post_class
          result = ::Inkwell::Constants::ItemTypes::POST
        else
          raise "obj should be Comment or #{post_class.class}"
      end
      result
    end

    def check_user(obj)
      user_class = Object.const_get ::Inkwell::Engine::config.user_table.to_s.singularize.capitalize
      raise "user should be a #{user_class.to_s}" unless obj.is_a? user_class
    end

    def check_post(obj)
      post_class = Object.const_get ::Inkwell::Engine::config.post_table.to_s.singularize.capitalize
      raise "post should be a #{user_class.to_s}" unless obj.is_a? post_class
    end
  end

  module Constants
    module ItemTypes
      POST = 'p'
      COMMENT = 'c'
    end
  end
end