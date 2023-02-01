# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Sanity check
require 'octokit'
require 'cgi'
require 'getoptlong'
require 'kramdown'
require 'yaml'

if ENV['GITHUB_ACTIONS'] != 'true'
  raise "This profile is only meant to be used with Github Actions"
end

# TODO: Need to clean this up a bit
# Use the github api to find the files changed between the two commits
# The token here is set by actions via secrets.GITHUB_TOKEN for the run.
# The event json doesn't have this data so I implement it here.
github = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'])
puts "Running under Github Actions"
puts "\tUsing default branch: #{ENV['DEFAULT_BRANCH']}"

repository     = ENV['GITHUB_REPOSITORY']
branch         = CGI.escape(ENV['GITHUB_REF'].sub('refs/heads/',''))

begin
 feature_branch = github.ref(repository,
                             "heads/#{branch}")

 master_branch  = github.ref(repository,
                             "heads/#{ENV['DEFAULT_BRANCH']}")
 comparison     = github.compare(repository,
                                 master_branch.object.sha,
                                 feature_branch.object.sha)
 
 # Sanity check
 if comparison.status == "identical"
   puts "Commits are identical (merge commit?)"
   skip_control 'all' 
 end
 
 # This filters our tests just down to the context of the PR's branch
 # TODO: should I use default_branch here from the API instead of master
 files_to_check = comparison.files.select do |file|
   file.status == 'added' or file.status == 'modified'
 end.map{|file| "#{ENV['MARKDOWN']}/#{file.filename}"}

rescue Octokit::NotFound => e
  puts "Branch #{ENV['GITHUB_REF']} no longer exists"
  puts "Unable to lookup files that changed: #{e.inspect}"
  skip_control 'all'
  files_to_check = []
end

# This syntax means an intersection of the two arrays.
# Functionaly it means, file those files that have been edited and match our glob
markdown_files = Dir.glob("#{ENV['MARKDOWN']}/#{ENV['FILE_PATTERN']}") & files_to_check

# Include our shared resources
include_controls "shared"

# Enumerate our matching markdown files
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
      # Loop through each type of code block 
      when :codeblock
        case section.options[:lang]
        when 'json'
          describe json_syntax(value: section.value) do
              it { should be_valid }
          end
        when /^shell|shell-session/
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
          if front_matter['products_used'].include?('terraform')
            describe terraform_syntax(hcl: section.value) do
                it { should be_valid }
            end
          # TODO: Update this when https://github.com/hashicorp/packer/pull/10500 is merged
          elsif front_matter['products_used'].include?('packer')
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
