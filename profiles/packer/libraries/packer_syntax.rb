class PackerSyntax < Inspec.resource(1)
  require 'shellwords'

  name 'packer_syntax'
 
  desc 'Call the linter command for packer'
 
  example "
      describe packer_syntax(hcl: '...') do
        it { should be_valid }
      end
  "

  attr_reader :name, :filename 


  def initialize(hcl:)
    @content  = hcl 
  end

  def valid?
    packer_command('fmt')
  end
  
  def method_missing(name)
    packer_command(name.to_s)
  end

  private

  def packer_command(action)
    result = inspec.command("echo #{Shellwords.escape(@content)} |
                   terraform #{action} -").result
    exit_status = result.exit_status
    if exit_status.zero?
      exit_status.zero?
    else
      raise Inspec::Exceptions::ResourceFailed,
        "packer validate failed: \n #{@content} #{result.stderr} #{result.stdout}"
    end
  end
end
