require 'spec_helper'
require 'ymlbill/cli'
require 'ymlbill/pdf_engine'
require 'ymlbill/pdf_engines/chromium'

RSpec.describe Ymlbill::CLI do
  let(:fixtures_dir) { File.expand_path('../fixtures', __dir__) }
  let(:invoice_path) { File.join(fixtures_dir, 'invoice.yml') }
  let(:invalid_yaml_path) { File.join(fixtures_dir, 'invalid.yml') }
  let(:missing_file_path) { File.join(fixtures_dir, 'missing.yml') }

  describe 'CLI invocation' do
    let(:fake_engine) { instance_double(Ymlbill::PdfEngines::Chromium) }

    before do
      allow(Ymlbill::PdfEngine).to receive(:build).and_return(fake_engine)
      allow(fake_engine).to receive(:render)
    end

    context 'with no arguments' do
      it 'shows error and help' do
        expect do
          Ymlbill::CLI.start(['generate'])
        end.to output(/INPUT_YAML/).to_stderr
      end
    end

    context 'with a valid YAML file' do
      it 'runs the full pipeline' do
        Ymlbill::CLI.start(['generate', invoice_path])

        expect(Ymlbill::PdfEngine).to have_received(:build)
        expect(fake_engine).to have_received(:render)
      end
    end

    context 'with --output flag' do
      it 'writes to the specified path' do
        Ymlbill::CLI.start(['generate', invoice_path, '-o', 'custom_output.pdf'])

        expect(fake_engine).to have_received(:render).with(
          hash_including(output_path: 'custom_output.pdf')
        )
      end

      it 'works with long form --output' do
        Ymlbill::CLI.start(['generate', invoice_path, '--output', 'another.pdf'])

        expect(fake_engine).to have_received(:render).with(
          hash_including(output_path: 'another.pdf')
        )
      end
    end

    context 'with --template flag' do
      let(:custom_template) { '/tmp/custom_cli_test.html.erb' }

      before do
        File.write(custom_template, '<html><body><%= data.document.number %></body></html>')
      end

      after do
        File.delete(custom_template) if File.exist?(custom_template)
      end

      it 'uses the custom template' do
        allow(Ymlbill::TemplateResolver).to receive(:resolve).and_return(custom_template)

        Ymlbill::CLI.start(['generate', invoice_path, '-t', custom_template])

        expect(Ymlbill::TemplateResolver).to have_received(:resolve).with(custom_template)
      end

      it 'works with long form --template' do
        allow(Ymlbill::TemplateResolver).to receive(:resolve).and_return(custom_template)

        Ymlbill::CLI.start(['generate', invoice_path, '--template', custom_template])

        expect(Ymlbill::TemplateResolver).to have_received(:resolve).with(custom_template)
      end
    end

    context 'when input file is missing' do
      it 'exits with code 3' do
        expect do
          Ymlbill::CLI.start(['generate', missing_file_path])
        end.to raise_error(SystemExit) { |error| expect(error.status).to eq(3) }
      end
    end

    context 'when YAML is invalid' do
      it 'exits with code 3' do
        expect do
          Ymlbill::CLI.start(['generate', invalid_yaml_path])
        end.to raise_error(SystemExit) { |error| expect(error.status).to eq(3) }
      end
    end

    context 'when template is missing' do
      before do
        allow(Ymlbill::TemplateResolver).to receive(:resolve).and_raise(Ymlbill::TemplateNotFoundError.new('Template not found'))
      end

      it 'exits with code 4' do
        expect do
          Ymlbill::CLI.start(['generate', invoice_path])
        end.to raise_error(SystemExit) { |error| expect(error.status).to eq(4) }
      end
    end

    context 'when template has render error' do
      before do
        allow_any_instance_of(Ymlbill::HtmlRenderer).to receive(:render).and_raise(Ymlbill::TemplateRenderError.new('Render failed'))
      end

      it 'exits with code 4' do
        expect do
          Ymlbill::CLI.start(['generate', invoice_path])
        end.to raise_error(SystemExit) { |error| expect(error.status).to eq(4) }
      end
    end

    context 'when PDF generation fails' do
      before do
        allow(fake_engine).to receive(:render).and_raise(Ymlbill::PdfGenerationError.new('PDF failed'))
      end

      it 'exits with code 5' do
        expect do
          Ymlbill::CLI.start(['generate', invoice_path])
        end.to raise_error(SystemExit) { |error| expect(error.status).to eq(5) }
      end
    end

    context 'with --version flag' do
      it 'prints version' do
        expect do
          Ymlbill::CLI.start(['--version'])
        end.to output(/ymlbill/).to_stdout
      end
    end

    context 'with --help or -h flag' do
      it 'shows available commands' do
        expect do
          Ymlbill::CLI.start(['--help'])
        end.to output(/generate/).to_stdout
      end

      it 'shows available commands with -h' do
        expect do
          Ymlbill::CLI.start(['-h'])
        end.to output(/generate/).to_stdout
      end
    end
  end
end
