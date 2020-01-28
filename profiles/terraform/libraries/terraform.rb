class Terraform < Inspec.resource(1)

  name 'terraform'
 
  desc 'A wrapper to create & destroy a tf file'
 
  example "
      describe terraform(filename: 'example.tf',content: '...') do
        it { should be_initialized }
        it { should be_valid }
      end
  "

  attr_reader :name, :filename 


  def initialize(opts = {})
    @filename = opts[:filename]
    @content  = opts[:content]
  end

  def initialized?
    terraform_command('init -backend=false -input=false')
  end

  def valid?
    terraform_command('fmt')
  end
  
  def method_missing(name)
    terraform_command(name.to_s)
  end

  private

  def terraform_command(action)
    result = inspec.command("echo \'#{@content}\' |
                   TF_IN_AUTOMATION=yes terraform #{action} -").result
    exit_status = result.exit_status
    if exit_status.zero?
      exit_status.zero?
    else
      raise Inspec::Exceptions::ResourceFailed,
        "Command failed: \n #{@content} #{result.stderr} #{result.stdout}"
    end
  end
end
