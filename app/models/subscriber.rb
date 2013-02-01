# == Schema Information
#
# Table name: subscribers
#
#  id         :integer          not null, primary key
#  email      :string(255)
#  is_accept  :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Subscriber < ActiveRecord::Base
	include ::SharedMethods::Paging  
	DEFAULT_ORDER = "#{self.table_name}.email ASC"

  attr_accessible :email
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_format_of :email, :with  => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  
  def self.load_data(params = {})
    paging_info = parse_paging_options(params)
    # Paginate with Will_paginate.
    self.paginate(:page => paging_info.page_id,
      :per_page => paging_info.page_size,
      :order => paging_info.sort_string)
  end

  protected
      # Parse params to PagingInfo object.
      def self.parse_paging_options(options, default_opts = {})
        if default_opts.blank?
          # This conditions will order records by directory and name first.
          default_opts = {
            :sort_criteria => DEFAULT_ORDER
          }
        end
        paging_options(options, default_opts)
      end
end
