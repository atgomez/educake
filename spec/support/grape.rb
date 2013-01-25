RSpec.configure do |config|
  config.include RSpec::Rails::RequestExampleGroup, :type => :request, :example_group => {
    :file_path => /spec\/api/
  }

  config.include Capybara::DSL, :type => :feature, :example_group => {
    :file_path => /spec\/api/
  }
  
  config.include Capybara::RSpecMatchers, :type => :feature, :example_group => {
    :file_path => /spec\/api/
  }
end
