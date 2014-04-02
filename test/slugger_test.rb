require 'test_helper'

class SluggerTest < MiniTest::Unit::TestCase

  class Book < ActiveRecord::Base
    include Slugger

    slug :title
  end

  test 'model doesn\'t use slugger by default' do
    assert !Class.new(ActiveRecord::Base) {
      self.abstract_class = true
    }.respond_to?(:slugger)
  end

  test 'models have a slugger when Slugger is included' do
    assert Class.new(ActiveRecord::Base) {
      include Slugger
      slug -> { SecureRandom.hex }
    }.slugger
  end

  test 'slug' do
    book = Book.new(:title => 'The Picture of Dorian Gray')
    book.save
    assert_equal 'the-picture-of-dorian-gray', book.slug

    book = Book.new(:title => 'The Picture/of Dorian Gray')
    book.save
    assert_equal 'the-picture/of-dorian-gray', book.slug
  end

  test 'finders' do
    book = Book.new(:title => 'The Picture of Dorian Gray')
    book.save
    assert Book.find('the-picture-of-dorian-gray')
  end

  test 'set_slug is called before_save' do
    klass = Class.new(ActiveRecord::Base) {
      self.table_name = 'books'
      include Slugger
      slug -> (b) { b.id.to_s }, :trigger => :before_save
    }

    object = klass.new
    object.save
    assert_equal "", object.slug
  end

  test 'set_slug is called before_validation' do
    klass = Class.new(ActiveRecord::Base) {
      self.table_name = 'books'
      include Slugger
      slug -> (b) { b.id.to_s }, :trigger => :before_validation
    }

    object = klass.new
    object.valid?
    assert_equal "", object.slug
  end

  test 'set_slug is called after_validation' do
    klass = Class.new(ActiveRecord::Base) {
      self.table_name = 'books'
      include Slugger
      slug -> (b) { b.id.to_s }, :trigger => :after_validation
    }

    object = klass.new
    object.valid?
    assert_equal "", object.slug
  end

  test 'set_slug is called before_create' do
    klass = Class.new(ActiveRecord::Base) {
      self.table_name = 'books'
      include Slugger
      slug -> (b) { b.id.to_s }, :trigger => :before_create
    }

    object = klass.new
    object.save
    assert_equal "", object.slug
  end

  test 'set_slug is called after_save' do
    klass = Class.new(ActiveRecord::Base) {
      self.table_name = 'books'
      include Slugger
      slug -> (b) { b.id.to_s }, :trigger => :after_save
    }

    object = klass.new
    object.save
    assert_equal object.id.to_s, object.slug
  end

end
