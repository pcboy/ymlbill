module Ymlbill
  class TemplateResolver
    DEFAULT_TEMPLATE_PATH = File.expand_path('templates/default.html.erb', __dir__)

    class << self
      def resolve(template_path)
        return DEFAULT_TEMPLATE_PATH if template_path.nil?

        unless File.exist?(template_path)
          raise TemplateNotFoundError, "Template not found: #{template_path}"
        end

        template_path
      end
    end
  end
end
