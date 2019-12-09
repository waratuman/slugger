# Slugger

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'slugger'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install slugger

## Usage

TODO: Write usage instructions here

Example:

    class Movie < ActiveRecord::Base
      include Slugger

      slug :title
    end

Example with history:

    class Movie < ActiveRecord::Base
      include Slugger

      slug :title, history: true
    end

Example with lambda:

    class Move < ActiveRecord::Base
      include Slugger
    
      slug -> (m) { m.name.split(/\s+/).map(&:parameterize).reverse.join('/') }
    end
    
Now in ApplicationController you can redirect old slugs:

    rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
    
    def record_not_found
      # redirect_to @post, :status => :moved_permanently
      slug = Slugger::Slug.where(:slug => params[:id]).first
      if slug.nil?
        render :text => '', :status => :not_found
      elsif slug.model
        redirect_to slug.model, :status => :moved_permanently
      elsif slug
        render :text => '', :status => :gone
      else
        render :text => '', :status => :not_found
      end
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
