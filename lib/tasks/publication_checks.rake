namespace :publication_checks do
  desc "Runs the PublicationChecks"
  task run: :environment do
    result = PublicationCheck::Runner.run_check
    puts result.report
    exit(2) if result.failed?
  end
end
