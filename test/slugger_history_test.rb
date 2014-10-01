# require 'test_helper'
#
# class SluggerHistoryTest < Minitest::Test
#
#   class Book < ActiveRecord::Base
#     include Slugger
#
#     slug :title, before_save: true, history: true
#   end
#
#   class Movie < ActiveRecord::Base
#     include Slugger
#
#     slug :title, history: true
#   end
#
#   def setup
#     Book.delete_all
#     Movie.delete_all
#     Slugger::Slug.delete_all
#   end
#
#   test 'slug history added on create (before_save callback)' do
#     book = Book.create(:title => 'The Picture of Dorian Gray')
#     assert_equal 'the-picture-of-dorian-gray', book.slug
#     assert_equal 'the-picture-of-dorian-gray', Slugger::Slug.first.slug
#   end
#
#   test 'slug history added on update (before_save callback)' do
#     book = Book.create(:title => 'The Picture of Dorian Gray')
#     assert_equal 'the-picture-of-dorian-gray', book.slug
#
#     book.title = 'Serenity'
#     book.save
#     assert_equal 'serenity', book.slug
#     assert_equal ['serenity', 'the-picture-of-dorian-gray'], Slugger::Slug.all.map(&:slug)
#   end
#
#   test 'slug history added on create (after_save callback)' do
#     movie = Movie.create(:title => 'The Picture of Dorian Gray')
#     assert_equal 'the-picture-of-dorian-gray', movie.slug
#     assert_equal 'the-picture-of-dorian-gray', Slugger::Slug.first.slug
#   end
#
#   test 'slug history added on update (after_save callback)' do
#     movie = Movie.create(:title => 'The Picture of Dorian Gray')
#     assert_equal 'the-picture-of-dorian-gray', movie.slug
#
#     movie.title = 'Serenity'
#     movie.save
#     assert_equal 'serenity', movie.slug
#     assert_equal ['serenity', 'the-picture-of-dorian-gray'], Slugger::Slug.all.map(&:slug)
#   end
#
#   test 'slug history isn\'t added if slug didn\'t change' do
#     movie = Movie.create(:title => 'The Picture of Dorian Gray')
#     assert_equal 'the-picture-of-dorian-gray', movie.slug
#
#     movie.title = 'Serenity'
#     movie.save
#     assert_equal 'serenity', movie.slug
#     assert_equal ['serenity', 'the-picture-of-dorian-gray'], Slugger::Slug.all.map(&:slug)
#
#     movie.save
#     assert_equal ['serenity', 'the-picture-of-dorian-gray'], Slugger::Slug.all.map(&:slug)
#   end
#
#   test 'slug history added on destroy' do
#     movie = Movie.create(:title => 'The Picture of Dorian Gray')
#     assert_equal 'the-picture-of-dorian-gray', movie.slug
#
#     movie.title = 'Serenity'
#     movie.save
#     assert_equal 'serenity', movie.slug
#     assert_equal ['serenity', 'the-picture-of-dorian-gray'], Slugger::Slug.all.map(&:slug)
#
#     movie.destroy
#     assert_equal ['serenity', 'the-picture-of-dorian-gray'], Slugger::Slug.all.map(&:slug)
#   end
#
# end
