require_relative 'pdf_engines/chromium'

module Ymlbill
  module PdfEngine
    def self.build
      PdfEngines::Chromium.new
    end
  end
end
