$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "inkwell/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "inkwell"
  s.version     = Inkwell::VERSION
  s.authors     = ["Salkar"]
  s.email       = ["sokolov.sergey.a@gmail.com"]
  s.homepage    = "https://github.com/salkar/inkwell"
  s.summary     = "Inkwell adds social networking features – comments, reblogs, favorites, ability to follow other people and view their timeline."
  s.description = "Inkwell adds social networking features – comments, reblogs, favorites, ability to follow other people and view their timeline."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "> 3.1"

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "sqlite3"
end
