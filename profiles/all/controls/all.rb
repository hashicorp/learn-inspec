 raise "No markdown files found! #{Dir.glob("/markdown/*").inspect}\n#{Dir.glob("/github/*").inspect}" 
include_controls 'vault'
include_controls 'terraform'
include_controls 'consul'
include_controls 'nomad'
