# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

class YamlSyntax < Inspec.resource(1)

  name 'yaml_syntax'
 
  desc 'Syntax checker for yaml'
 
  example "
      describe yaml_syntax(value: '...') do
        it { should be_valid }
      end
  "

  attr_reader :name

  def initialize(value:)
    @value  = value 
  end

  def valid?
    validate_yaml(@value) 
  end
  

  private

  def validate_yaml(value)
    YAML.load(value)
  rescue => error
    raise Inspec::Exceptions::ResourceFailed,
      "yaml is invalid: \n #{@value} \n #{error.message}"
  end
end
