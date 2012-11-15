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

  # SCOPE

  # Get all students in scope of the input teacher
  scope :students_of_teacher, lambda { |teacher|
    # Get all teacher ids instead of joining two tables :users and :students.
    # Maybe faster?
    teacher_ids = teacher.children.select([:id, :parent_id]).collect(&:id)
    teacher_ids << teacher.id
    where(:teacher_id => teacher_ids)
  }

  # Class methods
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

  def shared_users_with_role(role_name)
    role = Role.where(:name => role_name.to_s.titleize).first
    # Detect shared users base on sharing role.
    self.shared_users.where("#{StudentSharing.table_name}.role_id = ?", role.try(:id))
  end

  # Return list of all teachers, including shared teachers.
  def shared_teachers
    self.shared_users_with_role(:teacher)
  end

end

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

