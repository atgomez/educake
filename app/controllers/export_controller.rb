class ExportController < ApplicationController
	cross_role_action :export_student
	def export_student
		xlsx_package = Axlsx::Package.new
		@student = Student.find params[:id]
	    @goals = @student.goals.incomplete
	    
	    in_tmpdir do |tmpdir|
		  begin 
	      temp = Tempfile.new("posts.xlsx", tmpdir) 
	      @goals.each do |goal| 
	    	goal.export_xml(xlsx_package, self, tmpdir, temp.path)
	      end
	      
	      send_file temp.path, :filename => "student_export.xlsx", :type => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
	    ensure
	      temp.close 
	      temp.unlink
	    end
		end
	    
	end

	protected
		def in_tmpdir
		  path = File.expand_path "#{Rails.root.join('tmp')}/#{Time.now.to_i}#{rand(1000)}/"
		  FileUtils.mkdir_p( path )

		  yield( path )

		ensure
		  FileUtils.rm_rf( path ) if File.exists?( path )
		end
end