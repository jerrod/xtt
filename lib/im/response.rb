module IM
  class Response
    attr_accessor :user
    
    def initialize(message, buddy)
      @buddy = buddy

      ActiveRecord::Base.verify_active_connections!

      return if buddy.screen_name == 'aolsystemmsg' or buddy.screen_name == 'AOL System Msg'
      @user = User.find_by_aim_login(buddy.screen_name)
      if @user
        message = parse_message(message)
        reply = extract_command(message)
        @buddy.send_im "<HTML>#{reply}</HTML>"
      else
        buddy.send_im "I don't have you in my system. Please add your aim_login to your xtt account first."
      end
    end
    
    def extract_command(message)
      case message
        when "help": 
          "I'm a time-tracker bot. Send me a status message like <b>@project hacking on \#54</b> or 'commands' for a list of commands"
        when "status":
          if status = @user.statuses.latest
            code = (status.user.memberships.for(status.project) || status.project).code rescue "?"
            project = status.project ? "#{status.project.name} (@#{code})": "Out"
            "Your current status is: <b>#{project}</b> #{status.message}"
          else
            "No current status"
          end
        when "commands":
          "Available commands are: help, projects, commands, status."
        when "projects": 
          "Your projects are: #{user.memberships.map{|m| "@#{m.code} (#{m.project.name})"}.to_sentence}"
        else
          create_status(message)
      end
    end
    
    def create_status(message)
      status = @user.post(message, 'AIM')
      if status and status.project 
        reply = "Created status for <b>#{status.project.name}</b>: '<code>#{status.message}</code>'"
      else
        reply = "Out: '<code>#{status.message}</code>'"
      end
      if status and status.new_record? # not saved
        return "Couldn't create your status. Debug: #{status.errors.full_messages.join(";")}"
      else
        return reply
      end
    end
  
    def parse_message(msg)
      msg.chomp.gsub(/<[^>]+>/,"").strip # strip html
    end
  end
end
