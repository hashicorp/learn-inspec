
class HclSyntax < Inspec.resource(1)

  require 'shellwords'

  name 'hcl_syntax'
 
  desc 'A wrapper to create & destroy a tf file'
 
  example "
      describe hcl_syntax(hcl: '...') do
        it { should be_valid }
      end
  "

  attr_reader :name, :filename 


  def initialize(hcl:)
    @content  = hcl 
  end

  def valid?
    hclfmt_command()
  end
  
  private

  def hclfmt_command()
    result = inspec.command("echo #{Shellwords.escape(@content)} |
                   hclfmt").result
    exit_status = result.exit_status
    if exit_status.zero?
      exit_status.zero?
    else
      raise Inspec::Exceptions::ResourceFailed,
        "hclfmt validate failed: \n #{@content} #{result.stderr} #{result.stdout}"
    end
  end
end
