require 'ymlbill'
require 'ferrum'

RSpec.describe Ymlbill::PdfEngines::Chromium do
  let(:engine) { described_class.new }
  let(:html_path) { '/tmp/test.html' }
  let(:output_path) { '/tmp/test_output.pdf' }

  before do
    File.write(html_path, '<html><body>Test</body></html>')
  end

  after do
    File.delete(html_path) if File.exist?(html_path)
    File.delete(output_path) if File.exist?(output_path)
  end

  describe '#render' do
    it 'generates a PDF file at the output path' do
      engine.render(html_path: html_path, output_path: output_path)

      expect(File.exist?(output_path)).to be true
      expect(File.read(output_path)).to start_with('%PDF')
    end

    it 'raises PdfGenerationError when browser fails' do
      allow(Ferrum::Browser).to receive(:new).and_raise(Ferrum::Error.new('browser failed'))

      expect do
        engine.render(html_path: html_path, output_path: output_path)
      end.to raise_error(Ymlbill::PdfGenerationError, /Failed to generate PDF/)
    end
  end
end
