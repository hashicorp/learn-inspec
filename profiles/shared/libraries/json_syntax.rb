# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

class JsonSyntax < Inspec.resource(1)

  name 'json_syntax'
 
  desc 'Syntax checker for json'
 
  example "
      describe json_syntax(value: '...') do
        it { should be_valid }
      end
  "

  attr_reader :name

  def initialize(value:)
    @value  = value
    if value.match(/\.\.\./)
      return skip_resource \
        "Skipping test: cannot validate json with ellipsis: \n #{value}"
    end
  end

  def valid?
    validate_json(@value) 
  end
  

  private

  def validate_json(value)
    result = JSON.parse(value)
    result.is_a?(Hash) || result.is_a?(Array)
  rescue JSON::ParserError, TypeError => error
      raise Inspec::Exceptions::ResourceFailed,
        "JSON is invalid: \n #{@value} \n #{error.message}"
  end
end
