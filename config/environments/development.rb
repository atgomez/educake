TeacherMgnt::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # The line of code below will prevent loading files from /public/assets"
  # config.serve_static_assets = false
  
  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # Config mailer
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  config.action_mailer.delivery_method = :smtp
  
  # GMAIL
  # You can use another dev account: tpl.teacher.dev@gmail.com / tpl123456
  config.action_mailer.smtp_settings = {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :domain               => 'gmail.com',
    :user_name            => 'tpl.teacher.mailer',
    :password             => 'TplTeacher123456',
    :authentication       => 'plain',
    :enable_starttls_auto => true
  }

  # In order to auto-reload Grape API in development mode.
  # See https://github.com/intridea/grape/issues/131#issuecomment-10413342
  files = Dir["#{Rails.root}/app/api/**/*.rb"]
  api_reloader = ActiveSupport::FileUpdateChecker.new(files) do |reloader|
    times = files.map{|f| File.mtime(f) }
    files = files.map{|f| f }

    Rails.application.reload_routes!
    Rails.application.routes_reloader.reload!
    Rails.application.eager_load!
  end

  ActionDispatch::Reloader.to_prepare do
    api_reloader.execute_if_updated
  end
end
