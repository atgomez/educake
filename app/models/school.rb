# == Schema Information
#
# Table name: schools
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  address1   :string(255)      not null
#  address2   :string(255)
#  city       :string(255)
#  state      :string(255)      not null
#  zipcode    :string(255)
#  phone      :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class School < ActiveRecord::Base
  include ::SharedMethods::Paging
  attr_accessible :address1, :address2, :city, :name, :phone, :state, :zipcode, :admin_attributes
 
  # ASSOCIATIONS
  has_many :users, :dependent => :destroy

  # TODO: improve this association
  has_one :admin, :class_name => "User", :conditions => proc { 
            admin_id = Role[:admin].try(:id)
            "users.role_id = #{admin_id}"
          }

  accepts_nested_attributes_for :admin
  
  # VALIDATIONS
  validates_uniqueness_of :name, :scope => [:city, :state]
  validates_uniqueness_of :name, :scope => [:city]
  validates_uniqueness_of :name, :scope => [:state]
  validates_presence_of :address1, :name, :state, :phone
  validates_presence_of :city, :message => "City can't be blank."
  validates :zipcode, :length => { :maximum => 5, :too_long => "Zip code with %{count} characters is the maximum allowed" }
  validates :name, :length => { :maximum => 255, :too_long => "%{count} characters is the maximum allowed" }
 
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
    
    def load_data_with_admin(params = {})
      # TODO: this is a work-around to fix the issue of will_paginate
      # See: https://github.com/mislav/will_paginate/issues/45
      paging_info = parse_paging_options(params)
      sql = self.joins(:admin).select("DISTINCT schools.*, users.last_name, users.first_name").order(
                                      paging_info.sort_string).to_sql
      conds = { :page => paging_info.page_id,
                :per_page => paging_info.page_size,
                :order => paging_info.sort_string
              }

      School.paginate_by_sql(sql, conds)
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
      LEFT JOIN students ON students.teacher_id = users.id
    }).select("COALESCE(COUNT(users.id), 0) AS teachers_count,
        COALESCE(COUNT(students.id), 0) AS students_count").to_sql

    data = School.connection.execute(sql).first
    return {:teachers_count => data['teachers_count'].to_i, :students_count => data['students_count'].to_i}
  end
end
