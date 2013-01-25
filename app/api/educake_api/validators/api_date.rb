module EducakeAPI::Validators
  class APIDate < Grape::Validations::Validator
    def validate_param!(attr_name, params)
      date = ::Util.format_date(params[attr_name])
      if date.blank?
        throw :error, :status => 400, :message => "#{attr_name}: must be in 'mm-dd-yyyy' format"
      end
    end
  end
end