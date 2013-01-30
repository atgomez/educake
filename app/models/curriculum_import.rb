class CurriculumImport
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming

  attr_accessor :import_file, :curriculum_core_name

  # VALIDATION
  validates_presence_of :import_file
  validate :check_import_file_format
  validates :curriculum_core_name, :format => {:with => /^[^0-9!@#\$%\^&*+_=]+$/}, 
            :unless => :curriculum_core_name_blank?
  # validates_format_of :import_file, :with => %r{\.(csv)$}i, :message => I18n.t('common.file.wrong_csv_file_type')

  # Constructor
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def import_file_path
    if self.import_file.respond_to?(:path)
      self.import_file.path
    else
      self.import_file
    end
  end

  def persisted?
    false
  end

  # Init CurriculumImport with a default core name.
  def self.init_import
    obj = CurriculumImport.new
    obj.curriculum_core_name = CurriculumCore.first.try(:name)
    return obj
  end

  protected

    def actual_file_name
      if self.import_file.respond_to?(:original_filename)
        self.import_file.original_filename
      else
        self.import_file_path
      end
    end

    def check_import_file_format
      if self.actual_file_name
        unless self.actual_file_name.match(%r{\.(csv)$}i)
          self.errors.add(:import_file, I18n.t('common.file.wrong_csv_file_type'))
        end 
      end
    end

    def curriculum_core_name_blank?
      self.curriculum_core_name.blank?
    end
end
