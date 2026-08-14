require 'yaml'

RSpec.describe Ymlbill::DocumentLoader do
  let(:fixtures_dir) { File.join(__dir__, '..', 'fixtures') }

  describe '.load' do
    context 'when the file exists and is valid' do
      it 'loads the YAML and returns a hash' do
        path = File.join(fixtures_dir, 'invoice.yml')
        data = described_class.load(path)

        expect(data).to be_a(Hash)
        expect(data['document']['type']).to eq('invoice')
        expect(data['document']['number']).to eq('INV-2026-001')
      end
    end

    context 'when the file does not exist' do
      it 'raises InputFileNotFoundError' do
        path = File.join(fixtures_dir, 'nonexistent.yml')

        expect { described_class.load(path) }
          .to raise_error(Ymlbill::InputFileNotFoundError, /Input file not found/)
      end
    end

    context 'when the YAML syntax is invalid' do
      it 'raises InvalidYamlError' do
        path = File.join(fixtures_dir, 'invalid.yml')

        expect { described_class.load(path) }
          .to raise_error(Ymlbill::InvalidYamlError, /Invalid YAML syntax/)
      end
    end

    context 'when client and seller are string references' do
      it 'resolves them to loaded hashes' do
        path = File.join(fixtures_dir, 'invoice.yml')
        data = described_class.load(path)

        expect(data['client']).to be_a(Hash)
        expect(data['client']['name']).to eq('Client Company')
        expect(data['client']['address']['city']).to eq('Lyon')

        expect(data['seller']).to be_a(Hash)
        expect(data['seller']['name']).to eq('Acme Consulting')
        expect(data['seller']['address']['city']).to eq('Paris')
      end
    end

    context 'when client and seller are inline hashes' do
      it 'keeps them as-is without modification' do
        path = File.join(fixtures_dir, 'invoice_inline.yml')
        data = described_class.load(path)

        expect(data['client']).to be_a(Hash)
        expect(data['client']['name']).to eq('Inline Client')
        expect(data['client']['address']['city']).to eq('Client City')

        expect(data['seller']).to be_a(Hash)
        expect(data['seller']['name']).to eq('Inline Seller')
        expect(data['seller']['address']['city']).to eq('Seller City')
      end
    end

    context 'when references are relative to the invoice file directory' do
      it 'loads nested file paths correctly' do
        path = File.join(fixtures_dir, 'invoice.yml')
        data = described_class.load(path)

        expect(data['client']['email']).to eq('accounting@client.example')
        expect(data['seller']['email']).to eq('billing@acme.example')
      end
    end
  end
end
