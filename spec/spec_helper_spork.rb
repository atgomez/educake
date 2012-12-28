require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  require File.expand_path("../spec_helper_base", __FILE__)
end

Spork.each_run do
  I18n.backend.reload!
  FactoryGirl.reload
end
