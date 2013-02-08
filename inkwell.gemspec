$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "inkwell/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "inkwell"
  s.version     = Inkwell::VERSION
  s.authors     = ["Sergey Sokolov"]
  s.email       = ["sokolov.sergey.a@gmail.com"]
  s.homepage    = "https://github.com/salkar/inkwell#inkwell"
  s.summary     = "Inkwell provides simple way to add social networking features like comments, reblogs, favorites, following/followers, communities and timelines to your Ruby on Rails application."
  s.description = "Inkwell provides simple way to add social networking features like comments, reblogs, favorites, following/followers, communities and timelines to your Ruby on Rails application."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "railties", ">= 3.1.0"
  s.add_dependency "activerecord", ">= 3.1.0"

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rails", ">= 3.1.0"
end
