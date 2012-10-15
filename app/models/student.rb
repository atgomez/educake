class Student < ActiveRecord::Base
  include ::SharedMethods::Paging

  attr_accessible :birthday, :first_name, :gender, :last_name, :teacher_id, :photo
  belongs_to :teacher, :class_name => "User"
  has_attached_file :photo, :styles => { :small => "200x200>", :medium => "300x300>" }, 
                   :storage => :s3,
                   :s3_credentials => "#{Rails.root}/config/amazon_s3.yml",
                   :default_url => 'default-avatar.jpeg',
                   :path => "photos/:id/:style.:extension"
  #validates_attachment_size :photo, :less_than => 5.megabytes
 # validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png']

  # ASSOCIATION
  has_many :goals, :dependent => :destroy
  has_many :sharing, :class_name => "StudentSharing", :dependent => :destroy

  # VALIDATION
  validates_presence_of :first_name, :last_name, :birthday
  validates :first_name, :uniqueness => { :scope => [:last_name, :teacher_id],
    :message => "student's name should not be duplicated" }

  # Class methods
  class << self

    # Load data
    #
    # === Parameters
    #
    #   * params[:page_size]
    #   * params[:page_id]
    #
    def load_data(params = {})
      paging_info = parse_paging_options(params)
      # Paginate with Will_paginate.
      self.paginate(:page => paging_info.page_id,
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
      
  end # End class methods.

  # Instance methods

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

