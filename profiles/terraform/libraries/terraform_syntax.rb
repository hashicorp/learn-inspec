# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

class TerraformSyntax < Inspec.resource(1)
  require 'shellwords'

  name 'terraform_syntax'
 
  desc 'A wrapper to create & destroy a tf file'
 
  example "
      describe terraform_syntax(hcl: '...') do
        it { should be_valid }
      end
  "

  attr_reader :name, :filename 


  def initialize(hcl:)
    @content  = hcl 
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
    result = inspec.command("echo #{Shellwords.escape(@content)} |
                   TF_IN_AUTOMATION=yes terraform #{action} -").result
    exit_status = result.exit_status
    if exit_status.zero?
      exit_status.zero?
    else
      raise Inspec::Exceptions::ResourceFailed,
        "Terraform validate failed: \n #{@content} #{result.stderr} #{result.stdout}"
    end
  end
end
