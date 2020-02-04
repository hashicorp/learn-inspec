class Shell < Inspec.resource(1)

  require 'shellwords'

  name 'shell'
 
  desc 'Syntax checker for json'
 
  example "
      describe shell(value: '...') do
        it { should be_valid }
      end
  "

  attr_reader :name

  def initialize(value:)
    @value  = value 
  end

  def valid?
    validate_shell(@value) 
  end
  
  def parse_command(value)
    lines = value.lines.to_a

    # Gather lines with escape chars at the end
    escaped_lines = lines.select{|line| line.chomp[-1] == '\\'}

    if !escaped_lines.empty?
      # Handle multiline commands
      parsed_command = escaped_lines.append(lines.at(escaped_lines.count)).join
    elsif lines[0][0] == '$'
      # Handle singleline commands
      parsed_command = lines[0]
    elsif lines[0][0] == '#'
      # Handle comment at begining of code block
      parsed_command = lines[1]
    end

    parsed_command
  end

  def validate_shell(value)

    command = parse_command(value)

    # Skip if we can't parse the shell
    raise Inspec::Exceptions::ResourceSkipped,
      "Unable to parse shell: \n #{value}" if command.nil?

    result = inspec.command("echo #{Shellwords.escape(command.sub!(/^.*\$/, ''))} | sh -n").result
    exit_status = result.exit_status
    if exit_status.zero?
      exit_status.zero?
    else
      raise Inspec::Exceptions::ResourceFailed,
        "Invalid Shell Syntax: \n #{command} #{result.stderr} #{result.stdout}"
    end
  end
end
