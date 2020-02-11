class ShellSyntax < Inspec.resource(1)

  require 'shellwords'

  name 'shell_syntax'
 
  desc 'Syntax checker for shell'
 
  example "
      describe shell_syntax(value: '...', replacements: '...'') do
        it { should be_valid }
      end
  "

  attr_reader :name

  def initialize(value: ,replacements:)
    @value   = value
    @command = parse_command(replace_pseudo(value,replacements))

    # Skip criteria
    if @command.nil?
      return skip_resource \
        "Unable to parse shell command, codeblock lang mismatch? \n #{value}"
    elsif @command.match(/(<\w+.*\w+?>|\.\.\.)/)
      return skip_resource \
        "Skipping test: Pseudo variable or ellipses detected \n #{value}"
    end
  end

  def valid?
    validate_shell(@value,@command) 
  end

  def replace_pseudo(value,replacements)
    value.gsub(/<\w+.*\w+?>/,replacements)
  end

  def parse_escaped_lines(escaped_lines,lines)
    
    last_line = lines.at(escaped_lines.count)

    # Break our codeblock out as a shellwords array
    shellwords         = lines.join.shellsplit

    # Create a similar break out for just the escaped lines 
    escaped_shellwords = escaped_lines.join.shellsplit

    # When the two don't match we likely have addtional parsing needed.
    if escaped_shellwords.last != shellwords.at(escaped_shellwords.count - 1)
      parsed_command = escaped_lines.append(shellwords.at(escaped_shellwords.count - 1).shellescape)
    else
      parsed_command = escaped_lines.append(last_line)
    end

    parsed_command.join

  rescue ArgumentError => e
    if lines.join.scan(/^.*\$/).count > 1
      raise Inspec::Exceptions::ResourceFailed,
        "Multiple commands in a single block detected: \n #{lines.join}"
    else
      # Our library can't split an incomplete line
      # So stub it out and try again if we failed to parse
      #return parse_escaped_lines(escaped_lines, lines) \
      #  if e.message.match(/Unmatched double quote/)
      raise Inspec::Exceptions::ResourceSkipped,
        "Unable to recontruct the full command: \
          #{escaped_lines.join} from \n #{lines.join} \
          The Error was #{e.message} \n #{e.backtrace}"
    end
  end

  def parse_command(value)
    lines = value.lines.to_a

    # Gather lines with escape chars at the end
    escaped_lines = lines.select{|line| line.chomp[-1] == '\\'}

    if !escaped_lines.empty?
      # Handle multiline commands
      parsed_command = parse_escaped_lines(escaped_lines, lines)
    elsif lines[0].lstrip[0] == '$'
      # Handle singleline commands
      parsed_command = lines[0].lstrip
    elsif lines[0].lstrip[0] == '#'
      # Handle comment at line 0 of the code block 
      parsed_command = lines[1].lstrip
    elsif lines[0].lstrip[0] == '/'
      # Handle docker exec style prompts
      parsed_command = lines[0].lstrip.sub(%r{^/}, '').lstrip
    end

    parsed_command
  end

  def validate_shell(value,command)

    # Skip if we can't parse the shell
    raise Inspec::Exceptions::ResourceSkipped,
      "Unable to parse shell: \n #{value}" if command.nil?

    result = inspec.command("echo #{Shellwords.escape(command.sub!(/^.*$/,''))} | sh -n").result
    exit_status = result.exit_status
    if exit_status.zero?
      exit_status.zero?
    else
      raise Inspec::Exceptions::ResourceFailed,
        "Invalid Shell Syntax: \n #{value} Parsed as \n#{command} #{result.stderr} #{result.stdout}"
    end
  end
end
