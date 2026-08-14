require 'spec_helper'
require 'ymlbill/html_renderer'
require 'ymlbill/document_loader'

RSpec.describe Ymlbill::HtmlRenderer do
  let(:fixtures_dir) { File.expand_path('../fixtures', __dir__) }
  let(:invoice_path) { File.join(fixtures_dir, 'invoice.yml') }
  let(:data) { Ymlbill::DocumentLoader.load(invoice_path) }

  describe '#render' do
    context 'with the default template' do
      let(:renderer) { described_class.new(template_path: Ymlbill::TemplateResolver::DEFAULT_TEMPLATE_PATH, base_dir: fixtures_dir) }

      it 'renders YAML data into HTML' do
        html = renderer.render(data: data)

        expect(html).to include('<!DOCTYPE html>')
        expect(html).to include('Invoice')
        expect(html).to include('INV-2026-001')
        expect(html).to include('Acme Consulting')
        expect(html).to include('Client Company')
        expect(html).to include('Consulting services')
      end

      it 'includes seller payment info' do
        html = renderer.render(data: data)

        expect(html).to include('Payment Information')
        expect(html).to include('Bank: Example Bank')
      end

      it 'includes notes section' do
        html = renderer.render(data: data)

        expect(html).to include('Notes')
        expect(html).to include('Payment due within 14 days')
      end
    end

    context 'with a custom template' do
      let(:custom_template) { '/tmp/custom_renderer_test.html.erb' }

      before do
        File.write(custom_template, '<html><body><%= data.document.number %></body></html>')
      end

      after do
        File.delete(custom_template)
      end

      it 'renders using the custom template' do
        renderer = described_class.new(template_path: custom_template, base_dir: fixtures_dir)
        html = renderer.render(data: data)

        expect(html).to include('INV-2026-001')
      end
    end

    context 'when template has syntax errors' do
      let(:bad_template) { '/tmp/bad_template.html.erb' }

      before do
        File.write(bad_template, '<html><%= data.document. %></html>')
      end

      after do
        File.delete(bad_template)
      end

      it 'raises TemplateRenderError' do
        renderer = described_class.new(template_path: bad_template, base_dir: fixtures_dir)

        expect do
          renderer.render(data: data)
        end.to raise_error(Ymlbill::TemplateRenderError)
      end
    end
  end
end
