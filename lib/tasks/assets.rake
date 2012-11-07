namespace :assets do
  desc "Re-package static assets (for production mode)"
  
  task :rebuild => ["force_clean", "assets:precompile"]
  
  # assets:clean does not fully cleanup the public/assets folder.
  task :force_clean => :environment do    
    asset_dir = File.join(Rails.root, "public/assets")
    puts "Cleaning up assets folder..."
    if !File.exist?(asset_dir)
      FileUtils.mkdir(asset_dir)
    else
      FileUtils.remove_dir(asset_dir)
      FileUtils.mkdir(asset_dir)
    end
  end
end
