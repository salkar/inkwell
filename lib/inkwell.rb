require 'inkwell/engine'
require 'inkwell/errors/not_favoritable'

module Inkwell
  mattr_accessor(:default_per_page){25}
  mattr_accessor(:favorites_per_page)
end
