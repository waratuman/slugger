require 'rubygems'
require 'bundler/setup'
require 'sqlite3'
require 'active_record'
require 'minitest/unit'
require 'turn/autorun'
require 'slugger'

module Slugger::Test
  
  module Database
    extend self

    def connect
      ActiveRecord::Base.establish_connection(YAML::load(<<-CONFIG))
        adapter: sqlite3
        database: ":memory:"
        encoding: utf8
      CONFIG
      
      ActiveRecord::Migration.verbose = false
      Schema.migrate :up
    end

    def disconnect!
      ActiveRecord::Base.connection.disconnect!
    end

  end

  class Schema < ActiveRecord::Migration

    def self.up
      create_table :books do |t|
        t.string  :title
        t.string  :author
        t.string  :slug, :unique => true
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