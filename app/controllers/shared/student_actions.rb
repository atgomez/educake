# TODO: refactor Admin controllers
module Shared::StudentActions
  def common_chart
    @series = []
    @student = Student.find params[:id]
    @goals = @student.goals.incomplete
    @goals.each do |goal| 
      data = []
      goal.statuses.each{|status| 
        data << [status.due_date, (status.accuracy*100).round / 100.0]
      }
      #data << [goal.due_date, goal.accuracy]
      #Sort data by due date
      unless data.empty?
        data = data.sort_by { |hsh| hsh[0] } 
        @series << {
                     :name => goal.name,
                     :data => data,
                     :goal_id => goal.id
                    }
      end
    end
    @series = @series.to_json
    @enable_marker = true
    render :template => 'students/common_chart', :layout => "chart"
  end
end
