require 'spec_helper'
require 'ymlbill/template_resolver'

RSpec.describe Ymlbill::TemplateResolver do
  let(:default_template_path) { Ymlbill::TemplateResolver::DEFAULT_TEMPLATE_PATH }

  describe '.resolve' do
    context 'when no template path is provided' do
      it 'returns the default template path' do
        result = described_class.resolve(nil)

        expect(result).to eq(default_template_path)
      end
    end

    context 'when a custom template path is provided' do
      let(:custom_template) { '/tmp/custom_template.html.erb' }

      before do
        File.write(custom_template, '<h1>Custom</h1>')
      end

      after do
        File.delete(custom_template)
      end

      it 'returns the custom template path when it exists' do
        result = described_class.resolve(custom_template)

        expect(result).to eq(custom_template)
      end

      it "raises TemplateNotFoundError when the custom template doesn't exist" do
        non_existent_path = '/tmp/non_existent_template.html.erb'

        expect do
          described_class.resolve(non_existent_path)
        end.to raise_error(
          Ymlbill::TemplateNotFoundError,
          "Template not found: #{non_existent_path}"
        )
      end
    end
  end
end
