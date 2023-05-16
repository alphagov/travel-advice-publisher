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
end
