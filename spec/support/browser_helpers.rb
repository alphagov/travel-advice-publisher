module BrowserHelpers
  def click_navbar_button(label)
    within(:css, "div.navbar") do
      click_button label
    end
  end
end

RSpec.configuration.include BrowserHelpers, type: :feature
