require File.dirname(__FILE__) + '/spec_helper'

describe "Net::TOC::Buddy" do

  before do
    @conn = mock Net::TOC::Connection
    @buddy = Net::TOC::Buddy.new "joesixpack", @conn
  end
  
  describe "parsing raw updates" do
  
    it "Sets a user offline" do  
      @buddy.should_receive(:update_status).with(:offline)
      @buddy.raw_update "Joe Sixpack:F:0:1223330187:0:user_type"
    end
  
    it "sets a user away" do
      @buddy.should_receive(:update_status).with(:away)
      @buddy.raw_update "youbetcha:T:0:1223306495:57: UU:0"
    end
  
    it "sets a user away if weird oddly-formatted missing user_type sent" do
      @buddy.should_receive(:update_status).with(:away)
      @buddy.raw_update "courtenay187:T:0:1223325191:0"  
    end

    it "sets a user idle" do
      @buddy.should_receive(:update_status).with(:idle)
      @buddy.raw_update "youbetcha:T:0:1223306495:57: C:0"
    end
  
    it "sends a user offline when they select 'offline'" do
      @buddy.should_receive(:update_status).with(:offline)
      @buddy.raw_update "vpilf:F:0:0:0:  :0"
    end

  end

  describe "setting states" do
    
    it "runs on_status :away callback" do
      block = Proc.new { raise }
      block.should_receive(:call)
      
      @buddy.on_status(:away) do 
        block.call
      end
      @buddy.send :update_status, :away
    end

    it "runs on_status for several states" do
      block = Proc.new {}
      block.should_receive(:call).twice
      
      @buddy.on_status(:away, :offline) do 
        block.call
      end
      @buddy.send :update_status, :away
      @buddy.send :update_status, :offline
    end
    
  end
end

# From the TOC1 spec:
# UPDATE_BUDDY:<Buddy User>:<Online? T/F>:<Evil Amount>:<Signon Time>:<IdleTime>:<UC>
#    This one command handles arrival/depart/updates.  Evil Amount is
#    a percentage, Signon Time is UNIX epoc, idle time is in minutes, UC (User Class)
#    is a two/three character string.
#    uc[0]:
#    ' '  - Ignore
#    'A'  - On AOL
#    uc[1]
#    ' '  - Ignore
#    'A'  - Oscar Admin
#    'U'  - Oscar Unconfirmed
#    'O'  - Oscar Normal
#    'C'  - User is on wireless
#    uc[2] 
#    '\0' - Ignore
#    ' '  - Ignore
#    'U'  - The user has set their unavailable flag.

# super.rails-production.dump.1223330922.63779.sql.bz2