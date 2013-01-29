module ApplicationHelper
  def edition_edit_link(edition)
    link_to (edition.draft? ? 'edit' : 'view details'), edit_admin_edition_path(edition)
  end

  def preview_edition_path(edition, cache = true)
    "#{Plek.current.find("private-frontend")}/travel-advice/#{edition.country_slug}" + "?edition=#{edition.version_number}&cache=#{Time.now().to_i}"
  end

  def timestamp(time)
    %{<time datetime="#{ time.strftime("%Y-%m-%dT%H:%M:%SZ") }">#{ time.strftime("%d/%m/%Y %H:%M") }</time>}.html_safe
  end

  def alert_statuses_with_labels(keys)
    # reverse keys so we list in order of decreasing severity
    keys.reverse.map {|key| [ I18n.t("alert_status.#{key}"), key ] }
  end
end
