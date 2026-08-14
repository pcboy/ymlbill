require 'ostruct'
require 'json'
require 'money'

module Ymlbill
  class HtmlRenderer
    def initialize(template_path:, base_dir: nil)
      @template_path = template_path
      @base_dir = base_dir
    end

    def render(data:)
      template_content = File.read(@template_path)

      data = JSON.parse(data.to_json, object_class: OpenStruct)

      erb = ERB.new(template_content, trim_mode: '-')
      erb.result(binding)
    rescue SyntaxError => e
      raise TemplateRenderError, "Template syntax error: #{e.message}"
    end

    def money(amount, currency = 'EUR')
      Money.new(amount * 100, currency.to_s.upcase).format(
        symbol: true, decimal_mark: '.', thousands_separator: ' '
      )
    end

    def logo_path(path)
      return nil unless path

      full_path = @base_dir ? File.join(@base_dir, path) : File.expand_path(path)
      full_path = File.expand_path(full_path)
      return nil unless File.exist?(full_path)

      ext = File.extname(full_path).downcase
      mime_type = case ext
                  when '.jpg', '.jpeg' then 'image/jpeg'
                  when '.svg' then 'image/svg+xml'
                  when '.gif' then 'image/gif'
                  when '.webp' then 'image/webp'
                  else 'image/png'
                  end

      content = File.read(full_path, mode: 'rb')
      base64 = [content].pack('m0')
      "data:#{mime_type};base64,#{base64}"
    rescue StandardError => e
      warn "Warning: Could not load logo from #{path}: #{e.message}"
      nil
    end
  end
end
