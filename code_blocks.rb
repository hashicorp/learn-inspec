#!/usr/bin/env inspec exec 
# http://www.anniehedgie.com/inspec-basics-1
# https://lollyrock.com/posts/inspec-for-docker
require 'kramdown'
require 'yaml'


JSON_FILE_REGEX = %r{(/|\s)?(?<json_filename>\S+\.json)}

# Enumerate our markdown files
Dir.glob('**/*.mdx').each do|file|

  # Load the front matter (no parsing needed)
  front_matter = YAML.load_file(file)

  # Each document is a control
  control front_matter['id'] do
    impact 1.0
    title front_matter['name']
    desc front_matter['description']

    # Parse the markdown
    raw_text  = File.read(file)
    mark_down = Kramdown::Document.new(raw_text, input: 'GFM')

    @last_json = nil

    describe file do
      mark_down.root.children.each_with_index do |section,index|
        case section.type
          # Parse the codeblocks
          when :codeblock
            lines = section.value.lines.to_a
            case section.options[:lang]
            when 'plaintext'
              # Gather lines with escape chars at the end
              escaped_lines = lines.select{|line| line.chomp[-1] == '\\'}
              if !escaped_lines.empty?
                # Handle multiline commands
                parsed_command = escaped_lines.append(lines.at(escaped_lines.count)).join
              elsif lines[0][0] == '$'
                # Handle singleline commands
                parsed_command = lines[0]
              end
          
              # Sanity check
              if parsed_command.nil?
                describe command("#{file}:#{section.options[:location]}") do
                  pending("Unable to parse code block: (#{lines.join})")
                end
                next
              end

              # If codeblock mentioned json file name assume it was the last json code block.
              if matched = parsed_command.match(JSON_FILE_REGEX)
                describe command("echo \'#{@last_json}\'> #{matched[:json_filename]}") do
                  its('exit_status') { should eq 0 }
                end
              end

              # Remove the shell prompt
              parsed_command.sub!(/^\$/, '')
              describe command(parsed_command) do
                its('exit_status') { should eq 0 }
              end
            when 'powershell'
              # Remove powershell tag
              # TODO: need a windows target for this
              lines.delete_at(0)
              lines.delete_at(-1)
            when 'json'
              #TODO: Validation here?
              @last_json = section.value 
            end
        end
      end
    end
  end
end
