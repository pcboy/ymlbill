require "ferrum"

module Ymlbill
  module PdfEngines
    class Chromium
      def render(html_path:, output_path:)
        browser = Ferrum::Browser.new(
          browser_path: ENV["BROWSER_PATH"],
          headless: true,
          browser_options: { "no-sandbox": nil }
        )

        browser.go_to("file://#{File.expand_path(html_path)}")
        browser.pdf(
          path: output_path,
          paperWidth: 8.27,
          paperHeight: 11.69,
          printBackground: true
        )
      rescue ::Ferrum::Error => e
        raise PdfGenerationError, "Failed to generate PDF: #{e.message}"
      ensure
        browser&.quit
      end
    end
  end
end
