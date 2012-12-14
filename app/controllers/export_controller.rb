class ExportController < ApplicationController
	authorize_resource :student, :user
	cross_role_action :export_student, :export_classroom, :export_school, :relay

	# This is used to redirect to suitable action base on 'data' parameter
	# GET /export/relay
	# Params
	# data
	# teacher_id
	# student_id

	def relay
		export_data_for = params[:data]
		case export_data_for
		when 'individual' 
			redirect_to export_student_export_index_path(:student_id => params[:student_id])
		when 'classroom'
			redirect_to export_classroom_export_index_path(:teacher_id => params[:teacher_id])
		when 'school'
			redirect_to export_school_export_index_path(:admin_id => params[:admin_id])
		else
			render_page_not_found
		end
	end

	# GET /export/export_student
	# Params
	# student_id Student ID
	#

	def export_student
		xlsx_package = Axlsx::Package.new
		@student = Student.find_by_id params[:student_id]
	  if (can?(:view, @student))
		  in_tmpdir do |tmpdir, path|
			 	@student.export_excel(xlsx_package, self, tmpdir, path)
			 	# Send file
	      send_file path, :filename => "student_export[#{@student.full_name}].xlsx", 
	      					:type => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
			end
		else
			render_unauthorized(:iframe => true)
		end
	end

	# GET /export/export_classroom
	# Params
	# teacher_id Teacher ID
	# 

	def export_classroom
		xlsx_package = Axlsx::Package.new
		@teacher = User.find_by_id params[:teacher_id]
	  if (can?(:view, @teacher))
		  in_tmpdir do |tmpdir, path|
			 	@teacher.export_excel(xlsx_package, self, tmpdir, path)
			 	# Send file
	      send_file path, :filename => "classroom_export[#{@teacher.full_name}].xlsx", 
	      					:type => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
			end
		else
			render_unauthorized(:iframe => true)
		end
	end

	# GET /export/export_school
	# Params
	# admin_id Admin ID
	# 

	def export_school
		xlsx_package = Axlsx::Package.new
		@user = User.find_by_id params[:admin_id]
	  if can?(:view, @user)
		  in_tmpdir do |tmpdir, path|
			 	@user.export_excel(xlsx_package, self, tmpdir, path)
			 	# Send file
	      send_file path, :filename => "school_export[#{@user.full_name}].xlsx", 
	      					:type => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
			end
		else
			render_unauthorized(:iframe => true)
		end
	end

	

	protected
		def in_tmpdir
		  path = File.expand_path "#{Rails.root.join('tmp')}/#{Time.now.to_i}#{rand(1000)}/"
		  FileUtils.mkdir_p( path )

		  begin 
		  	# Create temp file to export
	      temp = Tempfile.new("tempfile.xlsx", path) 
	      yield(path, temp.path) # Pass temp folder and the path of temp file
	     
		  ensure
	      temp.close 
	      temp.unlink
		  end

		ensure
		  FileUtils.rm_rf( path ) if File.exists?( path ) # Remove temp folder whatever happening
		end
end
