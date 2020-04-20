# Store Our Github API Calls in here 
Class Checks {

   attr_reader :branch
   attr_reader :repository

   def initialize(token)
     @token = token || ENV['GITHUB_TOKEN']
      # Use the github api to find the files changed between the two commits
      # The token here is set by actions via secrets.GITHUB_TOKEN for the run.
      # The event json doesn't have this data so I implement it here.
      @github         = Octokit::Client.new(:access_token => token)
      @repository     = ENV['GITHUB_REPOSITORY']
      @branch         = CGI.escape(ENV['GITHUB_REF'].sub('refs/heads/',''))
   end


   # Can't use the PR changes as we operate on push
   def get_diff_from(compare_branch)
     feature_branch = @github.ref(@repository,
                                 "heads/#{branch}")

     master_branch  = @github.ref(@repository,
                                 "heads/#{compare_branch}")
     comparison     = @github.compare(repository,
                                     master_branch.object.sha,
                                     feature_branch.object.sha)

     # Sanity check
     # TODO: Should we require exluding master merges?
     if comparison.status == "identical"
       return "Commits are identical (merge commit?)", []
     end

     # This filters our tests just down to the context of the PR's branch
     # TODO: should I use default_branch here from the API instead of master
     files_to_check = comparison.files.select do |file|
       file.status == 'added' or file.status == 'modified'
     end.map{|file| "#{ENV['MARKDOWN']}/#{file.filename}"}

     return nil, files_to_check
   rescue Octokit::NotFound
     return "Branch #{ENV['GITHUB_REF']} no longer exists", []
   end

}
