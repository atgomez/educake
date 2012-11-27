class ExportController < ApplicationController
	cross_role_action :export_student
	def export_student
		xlsx_package = Axlsx::Package.new
		@student = Student.find params[:student_id]
	    
	  in_tmpdir do |tmpdir|
	  	# Create First Page for student


	  	# Create Goal pages
		  begin 
	      temp = Tempfile.new("student.xlsx", tmpdir) 
	      @student.export_xml(xlsx_package, self, tmpdir, temp.path)
	      send_file temp.path, :filename => "student_export[#{@student.full_name}].xlsx", :type => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
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