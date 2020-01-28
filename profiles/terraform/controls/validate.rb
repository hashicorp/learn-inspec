#!/usr/bin/env ruby 
require 'getoptlong'
require 'kramdown'
require 'yaml'

markdown_files = Dir.glob("/learn/pages/terraform/**/*.mdx")

raise "No markdown files found!" if markdown_files.count.zero?

# Enumerate our markdown files
markdown_files.each do |file|
    # Load the front matter (no parsing needed)
  front_matter = YAML.load_file(file)
  control file do
    impact 1.0
    title front_matter['name']
    desc front_matter['description']


    # Sanity check
    raise("#{file} does not use terraform according to front matter") if \
      ! front_matter['products_used'].include?('Terraform') 


    # Parse the markdown
    markdown = Kramdown::Document.new(File.read(file), input: 'GFM')
    
    markdown.root.children.each_with_index do |section,index|
      case section.type
      # Parse the codeblocks
      when :codeblock
        case section.options[:lang]
        when 'hcl'
          format = [
            index,
            File.basename(file),
            section.options[:location],
            (section.options[:location] + section.value.lines.to_a.count)
          ]
          options = {
            filename: "%i_%s#%i-%i.tf" % format,
            content:  section.value
          }
          describe terraform(options) do
              #it { should be_initialized }
              it { should be_valid }
          end
        end
      end
    end
  end
end
