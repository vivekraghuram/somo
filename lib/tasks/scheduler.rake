desc "This task is called by the Heroku scheduler add-on"
task hourly: :environment do
  TwilioState.resend
end
