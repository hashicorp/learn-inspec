if ENV['GITHUB_ACTIONS'] != 'true'
  raise "This profile is only meant to be used with Github Actions"
end

require 'octokit'
require 'cgi'
require 'getoptlong'
require 'kramdown'
require 'yaml'

github = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'])
puts "Running under Github Actions"

repository     = ENV['GITHUB_REPOSITORY']

branch         = CGI.escape(ENV['GITHUB_REF'].sub('refs/heads/',''))

feature_branch = github.ref(repository,
                            "heads/#{branch}")
master_branch  = github.ref(repository,
                            'heads/master')
comparison        = github.compare(repository,
                                master_branch.object.sha,
                                feature_branch.object.sha)

# Sanity check
if comparison.status == "identical"
  puts "Commits are identical"
  skip_control 'all' 
end

files_to_check = comparison.files.select do |file|
  file.status == 'added' or file.status == 'modified'
end.map{|file| "#{ENV['MARKDOWN']}/#{file.filename}"}

markdown_files = Dir.glob("#{ENV['MARKDOWN']}/pages/**/*.mdx") && files_to_check 

raise "No markdown files found!}" if markdown_files.count.zero?

include_controls "shared"

# TODO: Can't use this as inspec.command doesn't work as inspec in nil
# See if statement below, should track down why this doesn't work
#   require_resource(profile: 'terraform',
#                    resource: 'terraform_syntax',
#                    as: 'hcl_syntax')


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
