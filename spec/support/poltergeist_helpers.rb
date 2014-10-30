module PoltergeistHelpers 

  def click_navbar_button(label)
    unfix_navbar
    within(:css, "div.navbar") do
      click_button label
    end
  end

  private

  # The bootstrap css class .navbar-fixed-bottom contains the style rule
  # position : 'fixed'
  # which fixes the navigation bar at the bottom of the viewport thus
  # removing the need to scroll to the end of the page.
  # The Capybara Poltergeist driver detects an overlaid element when
  # attempting to click a navbar button because of this style rule.
  # Remove this particular style before interacting with the navbar buttons.
  #
  def unfix_navbar
    page.execute_script("$('div.navbar').removeClass('navbar-fixed-bottom')");
  end
end

RSpec.configuration.include PoltergeistHelpers, :type => :feature
