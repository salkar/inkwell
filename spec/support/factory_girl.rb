RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
puts File.expand_path('../../factories', __FILE__)
FactoryGirl.definition_file_paths = [File.expand_path('../../factories', __FILE__)]
FactoryGirl.find_definitions