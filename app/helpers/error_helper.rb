module ErrorHelper
  def errors_for(object, attribute)
    object.errors.errors.filter_map do |error|
      if error.attribute == attribute
        {
          text: error.options[:message],
        }
      end
    end
  end
end
