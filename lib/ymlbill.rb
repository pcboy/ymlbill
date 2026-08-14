require 'yaml'
require 'erb'
require 'tempfile'

module Ymlbill
  class Error < StandardError; end
  class InputFileNotFoundError < Error; end
  class InvalidYamlError < Error; end
  class TemplateNotFoundError < Error; end
  class TemplateRenderError < Error; end
  class PdfGenerationError < Error; end
end

require_relative 'ymlbill/version'
require_relative 'ymlbill/cli'
require_relative 'ymlbill/document_loader'
require_relative 'ymlbill/template_resolver'
require_relative 'ymlbill/html_renderer'
require_relative 'ymlbill/pdf_engine'
