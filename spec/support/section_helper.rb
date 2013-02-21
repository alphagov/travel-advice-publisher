module SectionHelper
  def selector_of_section(section_name)
    case section_name
    when /^the fieldset labelled (.+)$/
      [:xpath, "//fieldset[legend[. = '#{$1}']]"]
    else
      raise "Can't find mapping from \"#{section_name}\" to a section."
    end
  end

  def within_section(section_name)
    within *selector_of_section(section_name) do
      yield
    end
  end
end

RSpec.configuration.include SectionHelper, :type => :feature
