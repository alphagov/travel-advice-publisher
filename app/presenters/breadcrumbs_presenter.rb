class BreadcrumbsPresenter
  def self.present
    {
      web_url: "/foreign-travel-advice",
      title: "Foreign travel advice",
      parent: {
        web_url: "/browse/abroad/travel-abroad",
        title: "Travel abroad",
        parent: {
          web_url: "/browse/abroad",
          title: "Passports, travel and living abroad",
          parent: nil
        }
      }
    }.as_json
  end

  def self.present_for_index
    {
      web_url: "/browse/abroad/travel-abroad",
      title: "Travel abroad",
      parent: {
        web_url: "/browse/abroad",
        title: "Passports, travel and living abroad",
        parent: nil
      }
    }.as_json
  end
end
