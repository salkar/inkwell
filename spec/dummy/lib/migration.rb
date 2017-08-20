class Migration < ActiveRecord::VERSION::MAJOR >= 5 ?
  ActiveRecord::Migration["#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}"] :
  ActiveRecord::Migration
end
