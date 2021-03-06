require 'rubygems'
require 'bundler/setup'
require 'sqlite3'
require 'rails'
require 'minitest/autorun'
require 'slugger'
require 'byebug'

module Slugger::Test

  module Database
    extend self

    def connect
      # ActiveRecord::Base.logger = Logger.new(STDOUT)
      # ActiveRecord::Base.logger.level = Logger::DEBUG

      ActiveRecord::Base.establish_connection(
        adapter: 'postgresql',
        database: 'slugger_test'
      )

      ActiveRecord::Migration.verbose = false
      Schema.migrate :up
    end

    def disconnect!
      ActiveRecord::Base.connection.disconnect!
    end

  end

  class Schema < ActiveRecord::Migration[5.2]

    def self.up
      enable_extension 'pgcrypto'

      execute <<-SQL
        DROP TABLE IF EXISTS authors, books, movies, slugs;
      SQL

      create_table :authors do |t|
        t.string  :name
      end

      create_table :books do |t|
        t.string  :title
        t.integer  :author_id
        t.string  :slug, :unique => true
      end

      create_table :movies, id: :uuid  do |t|
        t.string  :title
        t.string  :author
        t.string  :slug, :unique => true
      end

      create_table :slugs do |t|
        t.string   :model_type, :null => false
        t.integer  :model_id,   :null => false
        t.string   :slug,       :null => false
        t.timestamps null: false
      end

    end

    def self.down
      drop_table :books
    end

  end

end

class Module

  def test(name, &block)
    define_method("test_#{name.gsub(/[^a-z0-9']/i, "_")}".to_sym, &block)
  end

end

Slugger::Test::Database.connect
# at_exit { Slugger::Test::Database.disconnect! }
