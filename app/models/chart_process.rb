class ChartProcess

	DEFAULT_BORDER_STYLE = { :style => :thin, :color => "DDDDDD" }
	TITLE_NAME_STYLE = {:b => true, 
                        :sz => 13, 
                        :bg_color => 'EEEEEE',
                        :border => DEFAULT_BORDER_STYLE}
	LEFT_TEXT_STYLE = {:b => true, 
                     :bg_color => 'EEEEEE', 
                     :border => DEFAULT_BORDER_STYLE, 
                     :alignment => { :horizontal=> :right,
                                     :vertical => :top
                                  }
                    }
  BOLD_STYLE = {:b => true, 
                :border => DEFAULT_BORDER_STYLE }                  
  WRAP_TEXT = {:alignment => { :wrap_text => true }}

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

	def self.renderPNG(context, tmpdir, series_json)
    # Create tempfile
    random_number = (rand * 10000).to_i
    html_file = File.new(tmpdir + "/#{random_number.to_s}.html", 'wb',:encoding => 'ascii-8bit')
    f = File.new(tmpdir + "/#{random_number.to_s}.png", 'wb', :encoding => 'ascii-8bit')

    # Render PNG for the webpage
    html = context.render_to_string :template => 'charts/common_chart', :layout => "raw_script", :locals => {:series => series_json}
    html_file.write(html)
    file_content = self.render(html_file.path)
    
    # Include image to Sheets
    f.write(file_content)
    return f.path
  end
end
