class Json < Inspec.resource(1)

  name 'json'
 
  desc 'Syntax checker for json'
 
  example "
      describe json(value: '...') do
        it { should be_valid }
      end
  "

  attr_reader :name

  def initialize(value:)
    @value  = value 
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
