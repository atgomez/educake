# This is an approach to not have to run Spork everytime.
# See: http://stackoverflow.com/questions/8192636/rails-project-using-spork-always-have-to-use-spork

ENV["RAILS_ENV"] ||= 'test'

require 'rubygems'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Conditional Spork.prefork (this comment is needed to fool Spork's `bootstrapped?` check)
if /spork/i =~ $0 || RSpec.configuration.drb?
  puts "Loading spec_helper_spork ..."
  require File.expand_path("../spec_helper_spork", __FILE__)
else
  puts "Loading spec_helper_base ..."
  require File.expand_path("../spec_helper_base", __FILE__)
end
