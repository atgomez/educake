# == Schema Information
#
# Table name: schools
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  address1   :string(255)
#  address2   :string(255)
#  city       :string(255)
#  state      :string(255)
#  zipcode    :string(255)
#  phone      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class School < ActiveRecord::Base
  include ::SharedMethods::Paging
  attr_accessible :address1, :address2, :city, :name, :phone, :state, :zipcode, :users_attributes
 
  # ASSOCIATIONS
  has_many :users, :dependent => :destroy

  # TODO: improve this association
  has_one :admin, :class_name => "User", :conditions => proc { 
            admin_id = Role.with_name(:admin).first.try(:id)
            "users.role_id = #{admin_id}"
          }

  accepts_nested_attributes_for :users
  
  # VALIDATIONS
  validates_uniqueness_of :name, :scope => :city
  validates_presence_of :address1, :name, :state, :phone
  validates_presence_of :city, :message => "City can't be blank."
  validates :zipcode, :length => { :maximum => 5, :too_long => "%{count} characters is the maximum allowed" }
 
  # CLASS METHODS
  class << self
    def load_data(params = {})
      paging_info = parse_paging_options(params)
      # Paginate with Will_paginate.
      conds = { :page => paging_info.page_id,
                :per_page => paging_info.page_size,
                :order => paging_info.sort_string
              }
      self.paginate(conds)
    end
    
    def load_data_with_users(params = {})
      self.joins(:users).select("DISTINCT schools.*").load_data(params)
    end

    protected

      # Parse params to PagingInfo object.
      def parse_paging_options(options, default_opts = {})
        if default_opts.blank?
          # This conditions will order records by directory and name first.
          default_opts = {
            :sort_criteria => "name ASC"
          }
        end
        paging_options(options, default_opts)
      end
  end # End class method.

  def statistic
    # Generate SQL query to count teachers and students in a school.
    sql = self.users.teachers.joins(%Q{
      LEFT JOIN (
        SELECT teacher_id, count(students.id) AS students_count 
        FROM students
        GROUP BY teacher_id
      ) students_data ON students_data.teacher_id = "users"."id"
    }).select("COUNT(users.id) AS teachers_count, 
        COALESCE(SUM(students_data.students_count), 0) AS students_count").to_sql

    data = School.connection.execute(sql).first
    return {:teachers_count => data['teachers_count'].to_i, :students_count => data['students_count'].to_i}
  end
end
