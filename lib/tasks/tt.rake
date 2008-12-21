namespace :tt do
  task :notify => :environment do
    status = Status.find ENV['STATUS']
    project = status.project

    if project.nil? # don't send a message
      if status.previous.project 
        project = status.previous.project
      end
    end
    
    if project
      project.tendrils.each do |tendril|
        if status.created_at.utc < 6.hours.ago.utc
          timing = ((Time.now - status.created_at) / 1.hour).to_i
          tense = "was (#{timing} hours ago)"        
        elsif status.created_at.utc < 1.minute.ago.utc
          timing = ((Time.now - status.created_at) / 1.minute).to_i
          tense = "was (#{timing} mins ago)"
        else
          tense = "" # nothing. fuck you.
        end
        if status.out?
          previous = status.previous
          tendril.notifies.send_message "[XTT] #{status.user.login} #{tense} out, and no longer working on #{status.previous.project.name}: '#{status.message}'"
        else
          project = status.previous.project
          if project && project != status.project
            tendril.notifies.send_message "[XTT] #{status.user.login} switched projects, and #{tense} now \"#{status.message}\" on #{status.project.name}"
          elsif project.nil?
            tendril.notifies.send_message "[XTT] #{status.user.login} #{tense} back, \"#{status.message}\" on #{status.project.name}"
          else
            tendril.notifies.send_message "[XTT] #{status.user.login} #{tense} now \"#{status.message}\" still on #{status.project.name}"
          end
        end
      end
    end
  end
end