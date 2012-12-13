VERSION = '0.4'
build_num = ENV['BUILD_NUMBER'] || Time.now.utc.strftime('%Y-%m-%d %H:%M:%S %Z')
if match = build_num.match(/v+(\d+)$/) # In case the build number is come from Heroku, e.g, "v20", "v21", ...
  build_num = match[1]
end
BUILD_NUMBER = build_num
