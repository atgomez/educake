# encoding: UTF-8

class ChartProcess
	def self.render(html_file_path)

		platform = case RUBY_PLATFORM
		  when /x86_64-linux/i
		    '64'
		  when /linux/i
		    '32'
		  when /darwin/i
		    'mac'
		  else
		    raise "No binaries found for your system. Please install wkhtmltopdf by hand."
		end

		output = `#{Rails.root.join("bin/phantomjs-#{platform}")} #{Rails.root.join('bin/chart.js')} "#{html_file_path}"`
		Base64.decode64(output)
	end
end
