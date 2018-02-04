RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
FactoryBot.definition_file_paths = [File.expand_path('../../factories', __FILE__)]
FactoryBot.find_definitions