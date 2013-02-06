module Inkwell
  module Common
    def is_comment(obj)
      post_class = Object.const_get ::Inkwell::Engine::config.post_table.to_s.singularize.capitalize
      case obj
        when ::Inkwell::Comment
          is_comment = true
        when post_class
          is_comment = false
        else
          raise "obj should be Comment or #{post_class.class}"
      end
      is_comment
    end

    def check_user(obj)
      user_class = Object.const_get ::Inkwell::Engine::config.user_table.to_s.singularize.capitalize
      raise "user should be a #{user_class.to_s}" unless obj.is_a? user_class
    end
  end
end