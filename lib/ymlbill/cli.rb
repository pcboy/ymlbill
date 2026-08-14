require 'thor'
require 'tempfile'

module Ymlbill
  class CLI < Thor
    desc 'generate INPUT_YAML', 'Generate PDF invoice/quote from YAML file'
    option :template, aliases: ['-t'], type: :string, desc: 'Path to custom HTML ERB template'
    option :output, aliases: ['-o'], type: :string,
                    desc: 'Output PDF path (default: input basename + .pdf)'
    option :debug_html, aliases: ['-d'], type: :boolean, default: false,
                        desc: 'Keep HTML file for debugging'

    def generate(input_file)
      @input_file = input_file
      run_pipeline
    rescue InputFileNotFoundError, InvalidYamlError => e
      warn "Error: #{e.message}"
      exit 3
    rescue TemplateNotFoundError, TemplateRenderError => e
      warn "Error: #{e.message}"
      exit 4
    rescue PdfGenerationError => e
      warn "Error: #{e.message}"
      exit 5
    end

    desc '--version', 'Print version'
    def version
      puts "ymlbill #{Ymlbill::VERSION}"
    end

    map '--version' => :version
    map ['-h', '--help'] => :help

    private

    def run_pipeline
      data = DocumentLoader.load(@input_file)
      template_path = TemplateResolver.resolve(options[:template])
      base_dir = File.dirname(File.expand_path(@input_file))
      html = HtmlRenderer.new(template_path: template_path, base_dir: base_dir).render(data: data)

      output_path = options[:output] || default_output_path(@input_file)

      Tempfile.create(['ymlbill', '.html']) do |f|
        f.write(html)
        f.flush

        if options[:debug_html]
          debug_path = "#{File.basename(@input_file, '.*')}.html"
          File.write(debug_path, html)
          $stdout.puts "HTML saved to: #{debug_path}"
        end

        PdfEngine.build.render(html_path: f.path, output_path: output_path)
      end

      $stdout.puts "Generated: #{output_path}"
    end

    def default_output_path(input)
      basename = File.basename(input, '.*')
      "#{basename}.pdf"
    end
  end
end
