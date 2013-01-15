module ApplicationHelper
  def edition_edit_link(edition)
    link_to (edition.draft? ? 'edit' : 'view details'), edit_admin_edition_path(edition)
  end

  def timestamp(time)
    %{<time datetime="#{ time.strftime("%Y-%m-%dT%H:%M:%SZ") }">#{ time.strftime("%d/%m/%Y %H:%M") }</time>}.html_safe
  end

  # TODO: Establish whether both archive and publish workflow buttons should appear for drafts.
  def workflow_button(edition)
    %Q(<a href="#" class="workflow btn btn-danger pull-right">#{@edition.draft? ? 'Publish' : 'Archive'}</a>).html_safe
  end

  def workflow_form(edition)
    path = edition.draft? ? admin_editions_publish_path(edition) : admin_editions_archive_path(edition)
    
    form_tag path, :id => "edition_workflow", :method => :put do
      hidden_field_tag :id, edition.to_param
    end
  end

  def setup_association(edition, opts)
    associated = edition.parts

    opts.symbolize_keys!

    (opts[:new] - associated.select(&:new_record?).length).times  { associated.build } if opts[:new] and edition.new_record? == true
    if opts[:edit] and edition.new_record? == false
      (opts[:edit] - associated.count).times { associated.build }
    elsif opts[:new_in_edit] and edition.new_record? == false
      opts[:new_in_edit].times { associated.build }
    end
  end

end
