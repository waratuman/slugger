require 'rails/generators'
require 'rails/generators/active_record'

class SluggerGenerator < ActiveRecord::Generators::Base

  argument :name, type: :string, default: 'random_name'

  class_option 'skip-migration', :type => :boolean, :desc => 'Don\'t generate a migration for the slugs table'

  source_root File.expand_path('../../slugger', __FILE__)

  def copy_files
    return if options['skip-migration']
    migration_template 'migration.rb', 'db/migrate/create_slugger_slugs.rb'
  end

end