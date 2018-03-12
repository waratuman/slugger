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

  class Movie < ActiveRecord::Base
    include Slugger
    slug :title, trigger: :before_validation
  end

  def setup
    Book.delete_all
    Author.delete_all
    Movie.delete_all
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
    book = Book.create(title: 'The Picture of Dorian Gray')
    assert_equal 'the-picture-of-dorian-gray', book.slug

    book = Book.create(title: 'The Picture/of Dorian Gray')
    assert_equal 'the-picture/of-dorian-gray', book.slug
  end

  test 'to_param' do
    book = Book.create(:title => 'The Picture of Dorian Gray')
    assert_equal 'the-picture-of-dorian-gray', book.to_param
  end

  test 'ActiveRecord::Relation::find_one' do
    # Integer
    book = Book.create(:title => 'The Picture of Dorian Gray')
    assert_equal book, Book.find('the-picture-of-dorian-gray')
    assert_equal book, Book.find(book.id)

    # UUID
    id = SecureRandom.uuid
    movie = Movie.create(id: id, title: 'The Picture of Dorian Gray')
    assert_equal movie, Movie.find('the-picture-of-dorian-gray')
    # a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11
    assert_equal movie, Movie.find(id) 
    # A0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A11
    assert_equal movie, Movie.find(id.upcase) 
    # {a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11}
    assert_equal movie, Movie.find("{#{id}}") 
    # a0eebc999c0b4ef8bb6d6bb9bd380a11
    assert_equal movie, Movie.find(id.gsub('-', '')) 
    # a0ee-bc99-9c0b-4ef8-bb6d-6bb9-bd38-0a11    
    assert_equal movie, Movie.find(id.gsub('-', '').scan(/(.{4})/).join('-')) 
    # {a0eebc99-9c0b4ef8-bb6d6bb9-bd380a11}
    assert_equal movie, Movie.find("{" + id.gsub('-', '').scan(/(.{8})/).join('-') + "}") 
  end

  test 'ActiveRecord::Relation::find_some' do
    # Integer
    b1 = Book.create(title: 'The Picture of Dorian Gray')
    b2 = Book.create(title: 'The Lion, the Witch and the Wardrobe')
    assert_equal [b1,b2], Book.find('the-picture-of-dorian-gray', 'the-lion-the-witch-and-the-wardrobe')
    assert_equal [b1,b2], Book.find(b1.id, b2.id)
    
    # UUID
    id1, id2 = SecureRandom.uuid, SecureRandom.uuid
    m1 = Movie.create(id: id1, title: 'The Picture of Dorian Gray')
    m2 = Movie.create(id: id2, title: 'The Lion, the Witch and the Wardrobe')
# puts m1.id, id1, m2.id, id2
# byebug
    assert_equal [m1, m2], Movie.find('the-picture-of-dorian-gray', 'the-lion-the-witch-and-the-wardrobe')
    # a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11
    assert_equal [m1, m2], Movie.find(id1, id2) 
    # A0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A11
    # assert_equal [m1, m2], Movie.find([id1, id2].map(&:upcase)) 
    # {a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11}
    # assert_equal [m1, m2], Movie.find([id1, id2].map { |id| "{#{id}}" }) 
    # a0eebc999c0b4ef8bb6d6bb9bd380a11
    # assert_equal [m1, m2], Movie.find([id1, id2].map { |id| id.gsub('-', '') })
    # a0ee-bc99-9c0b-4ef8-bb6d-6bb9-bd38-0a11    
    # assert_equal [m1, m2], Movie.find([id1, id2].map { |id| id.gsub('-', '').scan(/(.{4})/).join('-') })
    # {a0eebc99-9c0b4ef8-bb6d6bb9-bd380a11}
    # assert_equal [m1, m2], Movie.find([id1, id2].map { |id| "{" + id.gsub('-', '').scan(/(.{8})/).join('-') + "}" }) 
  end

  test 'finders through association' do
    author = Author.create(name: 'Oscar Wilde')
    Book.create(title: 'The Picture of Dorian Gray', author: author)
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
