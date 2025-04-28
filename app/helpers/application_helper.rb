module ApplicationHelper
  def edition_edit_link(edition)
    link_content = edition.draft? ? "edit" : "view details"
    link_to(link_content, edit_admin_edition_path(edition), class: "govuk-link")
  end

  def preview_edition_link(edition, short, options = {})
    if edition.draft? || edition.scheduled?
      name = "Preview saved version"
      url = "#{Plek.external_url_for('draft-origin')}/foreign-travel-advice/#{edition.country_slug}?cache=#{Time.zone.now.to_i}"
    elsif edition.published?
      name = "View on site"
      url = "#{Plek.website_root}/foreign-travel-advice/#{edition.country_slug}?cache=#{Time.zone.now.to_i}"
    else
      name = "Print historical version"
      url = admin_edition_historical_edition_path(edition)
    end
    name = name.downcase.split(" ").first if short

    if options[:style_as_button]
      options = options.except(:style_as_button)

      return render "govuk_publishing_components/components/button", options.merge(
        text: name, href: url, secondary: true, target: "_blank",
      )
    end

    link_to(name, url, options.merge(target: "_blank", class: "govuk-link"))
  end

  def timestamp(time)
    %(<time datetime="#{time.strftime('%Y-%m-%dT%H:%M:%SZ')}">#{time.strftime('%d/%m/%Y %H:%M %Z')}</time>).html_safe
  end

  def alert_statuses_with_labels(keys)
    # reverse keys so we list in order of decreasing severity
    keys.reverse.map { |key| [I18n.t("alert_status.#{key}"), key] }
  end

  def diff_html(version1, version2)
    Diffy::Diff.new(version1.to_s, version2.to_s, allow_empty_diff: false).to_s(:html).html_safe
  end
end
