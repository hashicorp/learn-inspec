#!/usr/bin/env ruby 
require 'getoptlong'
require 'kramdown'
require 'yaml'

PRODUCTS_USED = ['Nomad','Nomad Enterprise']

markdown_files = Dir.glob("/learn/pages/nomad/**/*.mdx")

raise "No markdown files found!" if markdown_files.count.zero?

# Enumerate our markdown files
markdown_files.each do |file|
    # Load the front matter (no parsing needed)
  front_matter = YAML.load_file(file)
  control file do
    impact 1.0
    title front_matter['name']
    desc front_matter['description']

    ref File.basename(file),
      url: 'https://github.com/hashicorp/learn/blob/master/#{file.split("/").drop(1).join("/")}'

    # Sanity check
    only_if("#{file} does not contain front matter with #{PRODUCTS_USED}") do
      (front_matter['products_used'] & PRODUCTS_USED).any?
    end

    # Parse the markdown
    markdown = Kramdown::Document.new(File.read(file), input: 'GFM')
    
    markdown.root.children.each_with_index do |section,index|
      case section.type
      # Parse the codeblocks
      when :codeblock
        case section.options[:lang]
        when 'json'
          describe json(value: section.value) do
              it { should be_valid }
          end
        when 'shell'
          describe shell(value: section.value) do
              it { should be_valid }
          end
         when 'yaml'
           describe yaml(value: section.value) do
               it { should be_valid }
           end
        end
      end
    end
  end
end
