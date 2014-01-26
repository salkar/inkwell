module Inkwell
  if ::Inkwell::Engine::config.respond_to?('category_table')
    class BlogItemCategory < ActiveRecord::Base
    end
  end
end