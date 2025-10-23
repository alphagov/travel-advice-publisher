require 'spec_helper'

RSpec.describe FileSizeService do
  let(:service) { FileSizeService.new }
  let(:asset_url) { "https://assets.publishing.service.gov.uk/file.pdf" }
  let(:external_url) { "https://external-site.com/file.pdf" }
  let(:http_url) { "http://assets.publishing.service.gov.uk/file.pdf" }

  describe '#get_file_size_from_url' do
    context 'with valid URL and successful response' do
      let(:mock_response) { double('response', code: '200', '[]' => '1048576') }

      before do
        allow(service).to receive(:make_head_request).and_return(mock_response)
      end

      it 'returns file size in bytes' do
        expect(service.get_file_size_from_url(asset_url)).to eq(1048576)
      end

      it "allows environment-specific asset URLs" do
        # Use the actual Plek.asset_root domain for this environment
        plek_asset_host = URI(Plek.asset_root).host rescue "assets.publishing.service.gov.uk"
        env_asset_url = "https://#{plek_asset_host}/file.pdf"
        
        expect(service.get_file_size_from_url(env_asset_url)).to eq(1048576)
      end
    end

    context 'with invalid URL' do
      it 'returns nil for non-https URL' do
        expect(service.get_file_size_from_url(http_url)).to be_nil
      end

      it 'returns nil for untrusted domain' do
        expect(service.get_file_size_from_url(external_url)).to be_nil
      end

      it 'returns nil for malformed URL' do
        expect(service.get_file_size_from_url("not-a-url")).to be_nil
      end

      it "returns nil for nil URL" do
        expect(service.get_file_size_from_url(nil)).to be_nil
      end

      it "returns nil for non-string input" do
        expect(service.get_file_size_from_url(123)).to be_nil
      end

      it "returns nil for extremely long URLs" do
        long_url = "https://assets.publishing.service.gov.uk/" + "a" * 2000
        expect(service.get_file_size_from_url(long_url)).to be_nil
      end
    end

    context 'with large file sizes' do
      let(:mock_response) { double('response', code: '200', '[]' => (2.gigabytes).to_s) }

      before do
        allow(service).to receive(:make_head_request).and_return(mock_response)
      end

      it "rejects unreasonably large file sizes" do
        expect(service.get_file_size_from_url(asset_url)).to be_nil
      end
    end

    context 'with HTTP errors' do
      before do
        allow(service).to receive(:make_head_request).and_raise(StandardError.new("Network error"))
      end

      it 'returns nil and logs warning' do
        expect(Rails.logger).to receive(:warn).with(/File size request failed/)
        expect(service.get_file_size_from_url(asset_url)).to be_nil
      end
    end

    context 'with nil response' do
      before do
        allow(service).to receive(:make_head_request).and_return(nil)
      end

      it "handles nil response from HTTP client" do
        expect(service.get_file_size_from_url(asset_url)).to be_nil
      end
    end

    context 'with rate limiting' do
      it "allows up to 5 requests per service instance" do
        allow(service).to receive(:make_head_request).and_return(double('response', code: '200', '[]' => '1024'))
        
        5.times do
          expect(service.get_file_size_from_url(asset_url)).to eq(1024)
        end
      end

      it "blocks requests after the limit" do
        allow(service).to receive(:make_head_request).and_return(double('response', code: '200', '[]' => '1024'))
        
        5.times { service.get_file_size_from_url(asset_url) }
        
        expect(service.get_file_size_from_url(asset_url)).to be_nil
      end
    end
  end

  describe '#format_file_size' do
    it 'formats bytes correctly' do
      expect(service.format_file_size(512)).to eq("512 bytes")
    end

    it 'formats kilobytes correctly' do
      expect(service.format_file_size(1024)).to eq("1.0 KB")
      expect(service.format_file_size(1536)).to eq("1.5 KB")
    end

    it 'formats megabytes correctly' do
      expect(service.format_file_size(1048576)).to eq("1.0 MB")
      expect(service.format_file_size(1572864)).to eq("1.5 MB")
    end

    it 'formats gigabytes correctly' do
      expect(service.format_file_size(1073741824)).to eq("1.0 GB")
    end

    it 'returns empty string for nil input' do
      expect(service.format_file_size(nil)).to eq('')
    end

    it 'returns empty string for zero' do
      expect(service.format_file_size(0)).to eq('')
    end
  end

  describe '#safe_url_validation' do
    it 'accepts valid HTTPS URLs from trusted domains' do
      expect(service.send(:safe_url_validation, asset_url)).to be true
    end

    it "allows environment-specific asset URLs" do
      plek_asset_host = URI(Plek.asset_root).host rescue "assets.publishing.service.gov.uk"
      env_asset_url = "https://#{plek_asset_host}/file.pdf"
      
      expect(service.send(:safe_url_validation, env_asset_url)).to be true
    end

    it 'rejects HTTP URLs' do
      expect(service.send(:safe_url_validation, http_url)).to be false
    end

    it 'rejects untrusted domains' do
      expect(service.send(:safe_url_validation, external_url)).to be false
    end

    it 'rejects overly long URLs' do
      long_url = "https://assets.publishing.service.gov.uk/" + "a" * 2000
      expect(service.send(:safe_url_validation, long_url)).to be false
    end

    it 'rejects malformed URLs' do
      expect(service.send(:safe_url_validation, "not-a-url")).to be false
    end
  end
end