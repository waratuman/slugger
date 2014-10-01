require 'test_helper'

class SluggerTest < Minitest::Test

  class Book < ActiveRecord::Base
    include Slugger
    slug :title
    belongs_to :author
  end

  class Author < ActiveRecord::Base
    has_many :books

  end

  def setup
    Book.delete_all
    Author.delete_all
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

  test 'to_param' do
    book = Book.create(:title => 'The Picture of Dorian Gray')
    assert_equal 'the-picture-of-dorian-gray', book.to_param
  end

  test 'ActiveRecord::Relation::find_one' do
    book = Book.create(:title => 'The Picture of Dorian Gray')
    assert_equal book, Book.find('the-picture-of-dorian-gray')
    assert_equal book, Book.find(book.id)
  end

  test 'ActiveRecord::Relation::exists?' do
    book = Book.create(:title => 'The Picture of Dorian Gray')
    assert Book.exists?('the-picture-of-dorian-gray')
    assert Book.exists?(book.id)
  end

  test 'ActiveRecord::Relation::find_some' do
    b1 = Book.create(:title => 'The Picture of Dorian Gray')
    b2 = Book.create(:title => 'The Lion, the Witch and the Wardrobe')
    assert_equal [b1,b2], Book.find('the-picture-of-dorian-gray', 'the-lion-the-witch-and-the-wardrobe')
    assert_equal [b1,b2], Book.find(b1.id, b2.id)
  end

  test 'finders through association' do
    author = Author.create(name: 'Oscar Wilde')
    book = Book.create(title: 'The Picture of Dorian Gray', author: author)
    assert author.books.find('the-picture-of-dorian-gray')
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
