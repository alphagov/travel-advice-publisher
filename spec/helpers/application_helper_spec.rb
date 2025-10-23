require "spec_helper"

describe ApplicationHelper do
  describe "#diff_html" do
    it "Shows insertion diff" do
      result = diff_html("abcd", "abc123d")
      expect(result).to include('<li class="del"><del>abcd</del></li>')
      expect(result).to include('<li class="ins"><ins>abc<strong>123</strong>d</ins></li>')
    end

    it "Shows insertion diff from empty" do
      result = diff_html("", "abc123d")
      expect(result).to include('<li class="ins"><ins>abc123d</ins></li>')
    end

    it "Shows insertion diff from nil" do
      result = diff_html(nil, "abc123d")
      expect(result).to include('<li class="ins"><ins>abc123d</ins></li>')
    end

    it "Shows removal diff" do
      result = diff_html("abcd", "abd")
      expect(result).to include('<li class="del"><del>ab<strong>c</strong>d</del></li>')
      expect(result).to include('<li class="ins"><ins>abd</ins></li>')
    end

    it "Shows removal diff to empty" do
      result = diff_html("abcd", "")
      expect(result).to include('<li class="del"><del>abcd</del></li>')
    end

    it "Shows removal diff to nil" do
      result = diff_html("abcd", nil)
      expect(result).to include('<li class="del"><del>abcd</del></li>')
    end

    it "Shows unchanged diff" do
      result = diff_html("abc", "abc")
      expect(result).to include('<li class="unchanged"><span>abc</span></li>')
    end

    it "Shows unchanged empty diff" do
      result = diff_html("", "")
      expect(result).to include('<li class="unchanged"><span></span></li>')
    end

    it "Shows unchanged nil diff" do
      result = diff_html(nil, nil)
      expect(result).to include('<li class="unchanged"><span></span></li>')
    end
  end

  describe "#download_link_with_size" do
    let(:asset_url) { "https://assets.publishing.service.gov.uk/file.pdf" }

    it "creates a basic link when file size unavailable" do
      allow_any_instance_of(FileSizeService).to receive(:get_file_size_from_url).and_return(nil)
      
      result = helper.download_link_with_size("Download PDF", asset_url, class: "govuk-link")
      expect(result).to include('href="https://assets.publishing.service.gov.uk/file.pdf"')
      expect(result).to include('>Download PDF<')
      expect(result).to include('class="govuk-link"')
    end

    it "includes file size when available" do
      allow_any_instance_of(FileSizeService).to receive(:get_file_size_from_url).and_return(1048576)
      allow_any_instance_of(FileSizeService).to receive(:format_file_size).and_return("1 MB")
      
      result = helper.download_link_with_size("Download PDF", asset_url, class: "govuk-link")
      expect(result).to include('>Download PDF (1 MB)<')
    end

    it "handles nil URL gracefully" do
      result = helper.download_link_with_size("Download PDF", nil)
      expect(result).to include('<span>Download PDF</span>')
    end

    it "passes through link options" do
      allow_any_instance_of(FileSizeService).to receive(:get_file_size_from_url).and_return(nil)
      
      result = helper.download_link_with_size("Download PDF", asset_url, 
                                            class: "custom-class", 
                                            target: "_blank")
      expect(result).to include('class="custom-class"')
      expect(result).to include('target="_blank"')
    end
  end
end
