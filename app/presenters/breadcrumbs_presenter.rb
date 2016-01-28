class BreadcrumbsPresenter
  def self.present
    [
      {
        "content_id" => "08d48cdd-6b50-43ff-a53b-beab47f4aab0",
        "base_path" => "/foreign-travel-advice",
        "title" => "Foreign travel advice",
        "links" => { "parent" => ["b9849cd6-61a7-42dc-8124-362d2c7d48b0"] },
      },
      {
        "content_id" => "b9849cd6-61a7-42dc-8124-362d2c7d48b0",
        "base_path" => "/browse/abroad/travel-abroad",
        "title" => "Travel abroad",
        "links" => { "parent" => ["86eb717a-fb40-42e7-83fa-d031a03880fb"] },
      },
      {
        "content_id" => "86eb717a-fb40-42e7-83fa-d031a03880fb",
        "base_path" => "/browse/abroad",
        "title" => "Passports, travel and living abroad",
      }
    ]
  end

  def self.present_for_index
    [
     {
        "content_id" => "b9849cd6-61a7-42dc-8124-362d2c7d48b0",
        "base_path" => "/browse/abroad/travel-abroad",
        "title" => "Travel abroad",
        "links" => { "parent" => ["86eb717a-fb40-42e7-83fa-d031a03880fb"] },
      },
      {
        "content_id" => "86eb717a-fb40-42e7-83fa-d031a03880fb",
        "base_path" => "/browse/abroad",
        "title" => "Passports, travel and living abroad",
      }
    ]
  end
end
