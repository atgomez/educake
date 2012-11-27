class School < ActiveRecord::Base
  include ::SharedMethods::Paging
  attr_accessible :address1, :address2, :city, :name, :phone, :state, :zipcode, :users_attributes
  has_many :users, :dependent => :destroy
  accepts_nested_attributes_for :users
  
  validates_uniqueness_of :name, :scope => :city
  validates_presence_of :address1, :name, :state, :phone
  validates_presence_of :city, :message => "City can't be blank."
  validates_presence_of :zipcode, :message => "Zip code can't be blank."
  validates :zipcode, :length => { :maximum => 5,
    :too_long => "%{count} characters is the maximum allowed" }
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
end
