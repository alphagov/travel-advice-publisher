module ApplicationHelper
  def edition_edit_link(edition)
    link_to (edition.draft? ? 'edit' : 'view details'), edit_admin_edition_path(edition)
  end

  def preview_edition_path(edition, cache = true)
    if edition.latest_edition?
      "#{Plek.current.find("draft-origin")}/foreign-travel-advice/#{edition.country_slug}?cache=#{Time.now().to_i}"
    else
      admin_edition_preview_path(edition)
    end
  end

  def timestamp(time)
    %{<time datetime="#{ time.strftime("%Y-%m-%dT%H:%M:%SZ") }">#{ time.strftime("%d/%m/%Y %H:%M %Z") }</time>}.html_safe
  end

  def alert_statuses_with_labels(keys)
    # reverse keys so we list in order of decreasing severity
    keys.reverse.map {|key| [ I18n.t("alert_status.#{key}"), key ] }
  end

  def diff_html(version_1, version_2)
    Diffy::Diff.new(version_1, version_2, :allow_empty_diff => false).to_s(:html).html_safe
  end
end
