#!/usr/bin/env ruby 
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

require 'getoptlong'
require 'kramdown'
require 'yaml'

$config  = YAML.load(File.read("#{__dir__}/config.yaml"))

markdown_files = Dir.glob("#{ENV['MARKDOWN']}/#{$config['markdown_glob']}") 

raise "No markdown files found!}" if markdown_files.count.zero?

include_controls "shared"


# Enumerate our markdown files
markdown_files.each do |file|
    # Load the front matter (no parsing needed)
  front_matter = YAML.load_file(file)

  control file do
    impact 1.0
    title front_matter['page_title']
    desc front_matter['description']

    ref File.basename(file),
      url: 'https://github.com/hashicorp/learn/blob/master/#{file.split("/").drop(1).join("/")}'


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
          describe shell_syntax(value: section.value, replacements: input("replacements") ) do
              it { should be_valid }
          end
        when 'yaml'
          describe yaml_syntax(value: section.value) do
              it { should be_valid }
          end
        when 'hcl'
          describe hcl_syntax(hcl: section.value) do
              it { should be_valid }
          end
        end
      end
    end
  end
end
