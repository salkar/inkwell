# frozen_string_literal: true

$:.push File.expand_path("../lib", __FILE__)

require "inkwell/version"

Gem::Specification.new do |s|
  s.name        = "inkwell"
  s.version     = Inkwell::VERSION
  s.authors     = ["Sergey Sokolov"]
  s.email       = ["sokolov.sergey.a@gmail.com"]
  s.homepage    = "https://github.com/salkar/inkwell#inkwell"
  s.summary     = "Inkwell provides simple way to add social networking
features like comments, reblogs, favorites, following/followers,
communities, categories and timelines to your Ruby on Rails application."
  s.description = "Inkwell provides simple way to add social networking
features like comments, reblogs, favorites, following/followers,
communities, categories and timelines to your Ruby on Rails application."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*",
                "MIT-LICENSE",
                "Rakefile",
                "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency("rails", ">= 5", "< 6")
end
