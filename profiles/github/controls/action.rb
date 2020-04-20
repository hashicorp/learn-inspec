# Sanity check
require 'octokit'
require 'cgi'
require 'getoptlong'
require 'kramdown'
require 'yaml'
require_relative '../lib/checks.rb'

if ENV['GITHUB_ACTIONS'] != 'true'
  raise "This profile is only meant to be used with Github Actions"
end

checks = Checks.new(ENV['GITHUB_TOKEN'])

# Retrieve the changes file list from Github
err, files_to_check, exit_code = checks.get_diff_from('master')

# Merge commits are caught here
if err != nil 
  puts err
  skip_control 'all'
end if

# Functionaly it means, find those files that have been edited and match our glob
# This syntax (&) means an intersection of the two arrays.
markdown_files = Dir.glob("#{ENV['MARKDOWN']}/#{ENV['FILE_PATTERN']}") & files_to_check

# Include our shared (custom) *_syntax resources
include_controls "shared"

# Enumerate our matching markdown files
markdown_files.each do |file|
  # Load the front matter (no parsing needed)
  begin
    front_matter = YAML.load_file(file)
  rescue => error
    "Unable to parse YAML front matter: \n #{error.message}"
  end

  # YAML schema for learn vs the .io site differences
  page_title = front_matter['name'] || front_matter['page_title'] 

  products_used  = front_matter['products_used'] || [] 

  # Begining of the inspec control ( each file is a control  )
  control file do
    impact 1.0
    title page_title 
    desc front_matter['description']

    ref File.basename(file),
      url: 'https://github.com/hashicorp/learn/blob/master/#{file.split("/").drop(1).join("/")}'

    # Parse the markdown
    markdown = Kramdown::Document.new(File.read(file), input: 'GFM')

    markdown.root.children.each_with_index do |section,index|
      case section.type
      # Loop through each type of code block 
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
          # Use terraform to verify hcl for terraform products
          # TODO: Figure out why require_resource with an override causes
          # inspec.command not to work ( be nil )
          if products_used.include?('Terraform')
            describe terraform_syntax(hcl: section.value) do
                it { should be_valid }
            end
          else
            describe hcl_syntax(hcl: section.value) do
                it { should be_valid }
            end
          end
        end
      end
    end
  end
end
