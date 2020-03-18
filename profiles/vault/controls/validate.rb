#!/usr/bin/env ruby 
require 'getoptlong'
require 'kramdown'
require 'yaml'

$config  = YAML.load(File.read("#{__dir__}/config.yaml"))

PRODUCTS_USED = $config['products_used']

markdown_files = Dir.glob($config['markdown_glob'])

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
      products_used = (front_matter['products_used'] & PRODUCTS_USED)
      # The var evals to false with no front matter.
      # If its not false then check if any of the products match our config
      products_used &&
        products_used.any?
    end

    # Parse the markdown
    markdown = Kramdown::Document.new(File.read(file), input: 'GFM')
    
    markdown.root.children.each_with_index do |section,index|
      case section.type
      # Parse the codeblocks
      when :codeblock
        case section.options[:lang]
        when 'json'
          describe json_syntax(value: section.value) do
              it { should be_valid }
          end
        when 'shell'
          describe shell_syntax(value: section.value, replacements: $config['replacements'] ) do
              it { should be_valid }
          end
        when 'yaml'
          describe yaml_syntax(value: section.value) do
              it { should be_valid }
          end
        end
      end
    end
  end
end
