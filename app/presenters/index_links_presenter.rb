class IndexLinksPresenter
  def self.present
    {
      :links => {
        "parent" => BreadcrumbsPresenter.present_for_index
      }
    }
  end
end
