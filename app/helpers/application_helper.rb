module ApplicationHelper
  def edition_edlt_link(edition)
    link_to (edition.draft? ? 'edit' : 'view details'), edit_admin_edition_path(edition)
  end

  def timestamp(time)
    %{<time datetime="#{ time.strftime("%Y-%m-%dT%H:%M:%SZ") }">#{ time.strftime("%d/%m/%Y %H:%M") }</time>}.html_safe
  end
end
