# == Schema Information
#
# Table name: students
#
#  id                 :integer          not null, primary key
#  first_name         :string(255)      not null
#  last_name          :string(255)      not null
#  birthday           :date
#  teacher_id         :integer
#  gender             :boolean
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  photo_file_name    :string(255)
#  photo_content_type :string(255)
#  photo_file_size    :integer
#  photo_updated_at   :datetime
#

class Student < ActiveRecord::Base
  include ::SharedMethods::Paging

  attr_accessible :birthday, :first_name, :gender, :last_name, :teacher_id, :photo
  belongs_to :teacher, :class_name => "User"
  has_attached_file :photo, :styles => { :small => "88x88#",:medium => "200x200#" }, 
                   :storage => :s3,
                   :s3_credentials => "#{Rails.root}/config/amazon_s3.yml",
                   :default_url => 'default-avatar.jpeg',
                   :path => "photos/:id/:style.:extension"
  #validates_attachment_size :photo, :less_than => 5.megabytes
  validates_attachment_content_type :photo, :content_type => [ 'image/jpeg','image/png' ],
                                    :message => 'File must be of file type .jpg or .png'

  # ASSOCIATION
  has_many :goals, :dependent => :destroy
  has_many :sharings, :class_name => "StudentSharing", :dependent => :destroy
  has_many :shared_users, :through => :sharings, :source => :user

  # VALIDATION
  validates_presence_of :first_name, :last_name, :birthday
  validates_length_of :first_name, :maximum => 15
  validates_length_of :last_name, :maximum => 15
  validates :first_name, :uniqueness => { :scope => [:last_name, :teacher_id],
    :message => "student's name should not be duplicated" }

  validate :validate_type_of_image
  
  # SCOPE

  # Get all students in scope of the input teacher
  scope :students_of_teacher, lambda { |teacher|
    # Get all teacher ids instead of joining two tables :users and :students.
    # Maybe faster?
    teacher_ids = teacher.children.select([:id, :parent_id]).collect(&:id)
    teacher_ids << teacher.id
    where(:teacher_id => teacher_ids)
  }

  # CLASS METHODS

  class << self

    # Load data
    #
    # === Parameters
    #
    #   * params[:page_size]
    #   * params[:page_id]
    #
    def load_data(params = {}, ids = [])
      paging_info = parse_paging_options(params)
      # Paginate with Will_paginate.
      
      results = self.paginate(:page => paging_info.page_id,
          :per_page => paging_info.page_size,
          :order => paging_info.sort_string)
      results = results.where(:id => ids) unless ids.empty?
      return results
    end

    # Do a simple search
    #
    # === Parameters
    #
    #   * query(String): the query string
    #   * params[:page_size]
    #   * params[:page_id]
    #
    def search_data(query, params = {})
      return [] if query.blank?
      meta_keys = %w(first_name last_name)

      meta_key = build_meta_search_query(meta_keys)
      meta_query = {meta_key => query}

      paging_info = parse_paging_options(params)
      
      return self.search(meta_query).paginate(:page => paging_info.page_id,
                      :per_page => paging_info.page_size,
                      :order => paging_info.sort_string)
    end

    protected

      # Parse params to PagingInfo object.
      def parse_paging_options(options, default_opts = {})
        if default_opts.blank?
          # This conditions will order records by directory and name first.
          default_opts = {
            :sort_criteria => "first_name ASC, last_name ASC"
          }
        end
        paging_options(options, default_opts)
      end

      # Build query string for meta_search
      def build_meta_search_query(meta_keys)
        keys = meta_keys.join("_or_")
        keys << "_contains"
        return keys
      end
      
  end # End class methods.

  # Instance methods

  def validate_type_of_image
    return true if self.photo.original_filename.blank?

    type = self.photo.original_filename.split(".").last 
    unless %(jpg png).include?(type)
      self.errors.add(:photo, "File must be of file type .jpg or .png")
      return false
    end 
  end 
    
  def goals_statuses
    data = []
    progress = {}
    goals = self.goals
    goals.each do |goal|
      statuses = goal.statuses.computable.order("due_date ASC")
      statuses.map do |status|
        vs_baseline = status.value - goal.baseline
        progress[status.due_date] = [] if progress[status.due_date].nil?
        progress[status.due_date] << vs_baseline/(goal.accuracy - goal.baseline)*100
      end 
    end
    
    progress.keys.sort.each do |key| 
      data << [key, ((progress[key].sum/progress[key].count*100).round / 100.0)]
    end 
    return data
  end 
  def photo_url(style = :small)
    self.photo.url(style)
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def birthday_string
    ::Util.date_to_string(self.birthday)
  end

  # Override property setter.
  def birthday=(date)
    if date.is_a?(String)
      date = ::Util.format_date(date)
      if date
        date = date.to_date
      end
    end
    self.send(:write_attribute, :birthday, date)
  end
  
  def gender_string
    if self.gender.nil?
      I18n.t('common.gender.unknown')
    elsif self.gender
      I18n.t('common.gender.male')
    else
      I18n.t('common.gender.female')
    end    
  end

  # Get all sponsors of this student including teachers, parents (except the Admin)
  #
  # === Parameters
  #
  #   * with_role_name (String/Symbol)(optional): name of role needs filtering
  #
  # === Returns
  #
  #   An ActiveRecord::Relation object
  #
  def sponsors(with_role_name = nil)
    if with_role_name.blank?
      shared_users_sql = self.shared_users.to_sql
    else
      shared_users_sql = self.shared_users_with_role(with_role_name).to_sql
    end

    union_sql = %Q{
                (SELECT DISTINCT * FROM (SELECT * FROM users WHERE id=#{self.teacher_id}
                  UNION ALL 
                SELECT * FROM (#{shared_users_sql}) d2) data) users
              }
    User.from(union_sql).order("users.first_name ASC, users.last_name ASC")
  end

  # Get all users that are shared for this student including teachers, parents.
  #
  # === Parameters
  #
  #   * role_name (String/Symbol)(optional): name of role needs filtering
  #
  # === Returns
  #
  #   An ActiveRecord::Relation object
  #
  def shared_users_with_role(role_name)
    role = Role[role_name]
    # Detect shared users base on sharing role.
    self.shared_users.where("#{StudentSharing.table_name}.role_id = ?", role.try(:id))
  end

  # Get all teachers that are sponsoring this student.
  #
  # === Returns
  #
  #   An ActiveRecord::Relation object
  #
  def sponsoring_teachers
    self.sponsors(:teacher)
  end

  # Check on-track for student
  #
  # === Returns
  #
  #   * 0 : N/A (Not available)
  #   * 1 : on-track
  #   * 2 : not on-track
  #
  def check_on_track?
    result = 0 

    self.goals.incomplete.each do |goal|
      if !goal.on_track?
        # Student status will not be on-track if there is any goal not on-track.
        result = 2
        break
      else
        # On-track if all goals are on-track.
        result = 1
      end
    end

    return result  
  end

  # EXPORTING
  def export_xml(package, context, tmpdir, file_path)
    goals = self.goals.incomplete

    # Create First Page Info
    package.workbook.add_worksheet(:name => "Overall Status") do |sheet|
      # Styling
      student_name_style = sheet.styles.add_style ChartProcess::STUDENT_NAME_STYLE
      left_text_style = sheet.styles.add_style ChartProcess::LEFT_TEXT_STYLE
      bold = sheet.styles.add_style ChartProcess::BOLD_STYLE

      # Start adding row
      sheet.add_row [self.full_name, "", "", "", "", "", "", "", 
                     "", "", "", "", "", "", "", "", "", "", "", 
                     "", "","", "","", "","", "","", "","", "",], :style => student_name_style
      sheet.add_row [nil], :style => left_text_style
      sheet.add_row ["Report Date:", Date.today], :style => [left_text_style, nil]
      sheet.add_row [nil], :style => left_text_style
      sheet.add_row [nil, "Status", "Due Date", "On Track"], :style => [left_text_style, bold, bold, bold]
      goals.each do |goal| 
        sheet.add_row [goal.name, "#{(goal.goal_status*100).round / 100.0}%", 
                      goal.due_date, 
                      goal.on_track? ? "ok" : "not ok"],
                      :style => [left_text_style, nil]
      end
      (1..100).each do 
        sheet.add_row [nil], :style => left_text_style
      end

      # Create tempfile
      random_number = (rand * 10000).to_i
      html_file = File.new(tmpdir + "/#{random_number.to_s}.html", 'wb',:encoding => 'ascii-8bit')
      f = File.new(tmpdir + "/#{random_number.to_s}.png", 'wb', :encoding => 'ascii-8bit')

      # Render PNG for the webpage
      html = context.render_to_string :template => 'students/common_chart', :layout => "raw_script", :locals => {:series => self.series_json}
      html_file.write(html)
      file_content = ChartProcess.render(html_file.path)
      
      # Include image to Sheets
      f.write(file_content)

      # Add Chart to first page
      sheet.add_image(:image_src => f.path, :noSelect => true, :noMove => true) do |image|
        image.width=1000
        image.height=500
        image.start_at 6, 2
      end

    end

    # Export Goals

    idx = 1
    goals.each do |goal| 
      goal.export_xml(package, context, tmpdir, idx) do |sheet|
        student_name_style = sheet.styles.add_style ChartProcess::STUDENT_NAME_STYLE
        left_text_style = sheet.styles.add_style ChartProcess::LEFT_TEXT_STYLE

        sheet.add_row [self.full_name, "", "", "", "", "", "", "", 
                     "", "", "", "", "", "", "", "", "", "", "", 
                     "", "","", "","", "","", "","", "","", "",], :style => student_name_style
        sheet.add_row [nil], :style => left_text_style
      end
      idx = idx + 1
    end

    package.serialize(file_path)
  end

  # Collect data for charting

  def series_json(params={})
    goals = self.goals.incomplete
    series = []
    goals.each do |goal| 
      data = []
      goal.statuses.each{|status| 
        data << [status.due_date, (status.accuracy*100).round / 100.0]
      }
      #data << [goal.due_date, goal.accuracy]
      #Sort data by due date
      unless data.empty?
        data = data.sort_by { |hsh| hsh[0] } 
        series << {
                     :name => goal.name,
                     :data => data,
                     :item_id => goal.id
                    }
      end
    end
    series.to_json
  end
end
