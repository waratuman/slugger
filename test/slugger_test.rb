require 'test_helper'

class Book < ActiveRecord::Base
  include Slugger

  slug :title
end

class SluggerTest < MiniTest::Unit::TestCase

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

end
