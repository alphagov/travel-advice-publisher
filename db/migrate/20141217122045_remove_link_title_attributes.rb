class RemoveLinkTitleAttributes < Mongoid::Migration
  LINK_REGEX = %r{
                (\[.*?\])           # link text in literal square brackets
                \(                # literal opening parenthesis
                  (\S*?)           # containing URL
                  (\s+"[^"]+")?    # and optional space followed by title text in quotes
                \)                # literal close paren
                (\{:rel=["']external["']\})?  # optional :rel=external in literal curly brackets.
              }x.freeze

  def self.up
    TravelAdviceEdition.where(:state.in => %w[draft published]).order(%i[country_slug asc]).each do |edition|
      @messages = []
      edition.summary = sanitise_links(edition.summary)
      edition.parts.each_with_index do |part, index|
        edition.parts[index].body = sanitise_links(part.body)
      end
      if @messages.any?
        puts edition.country_slug
        if edition.valid? || (!has_error?(:summary, edition) && !has_error?(:parts, edition))
          edition.save!(validate: false)
          puts "Saved. Updated links: #{@messages.join(',')}"
        else
          puts "Failed to validate and save Edition."
          puts "Summary #{edition.errors[:summary].join(', ')}" if has_error?(:summary, edition)
          puts "Parts #{edition.errors[:parts].join(', ')}" if has_error?(:parts, edition)
        end
        puts "---------------------------------------------------------------"
      end
    end
  end

  def self.down; end

private

  def self.has_error?(key, edition)
    edition.errors.has_key?(key) && edition.errors[key].flatten.compact.any?
  end

  def self.sanitise_links(str)
    str.gsub(/(“|”)+/, '"').gsub(LINK_REGEX) do |link|
      link_text_md  = $1
      link_url      = $2
      link_title    = $3
      link_rel      = $4

      prepend_scheme = link_url =~ /\Awww/

      if link_title || link_rel || prepend_scheme
        link_url = "http://#{link_url}" if prepend_scheme
        @messages << "#{link_text_md}(#{link_url})"
        "#{link_text_md}(#{link_url})"
      else
        link
      end
    end
  end
end
