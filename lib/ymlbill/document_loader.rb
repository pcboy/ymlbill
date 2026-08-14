module Ymlbill
  class DocumentLoader
    def self.load(path)
      raise InputFileNotFoundError, "Input file not found: #{path}" unless File.exist?(path)

      yaml_content = File.read(path)
      data = YAML.safe_load(yaml_content, permitted_classes: [Date])

      raise InvalidYamlError, "YAML must be a hash, got #{data.class}" unless data.is_a?(Hash)

      base_dir = File.dirname(path)

      %w[seller client].each do |x|
        data[x] = load(File.join(base_dir, data[x])) if data[x].is_a?(String)
      end

      data
    rescue ::SyntaxError, Psych::SyntaxError => e
      raise InvalidYamlError, "Invalid YAML syntax: #{e.message}"
    end
  end
end
