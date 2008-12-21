class Feed < ActiveRecord::Base
  belongs_to :user # created_by
  belongs_to :project
  concerns :xml_parser
  
  def self.options
    options = {
      :token => "77459a191adae96b08496546ed4ee3da10e06ae7",
      :users => {
        'court3nay' => '77459a191adae96b08496546ed4ee3da10e06ae7'
      },
      :account => 'http://court3nay.lighthouseapp.com',
      :project => 7009
    }
  end
  
  def self.ticket_url(ticket)
    "FAIL"
    #{}"%s/projects/%s/tickets/%s" % [options[:account], options[:project], ticket]
  end
  
  def items
    #URI.parse('%s/projects/%d/tickets.xml?_token=%s' % [options[:account], options[:project], options[:token]])
    
    items = Feed.run(URI.parse(url))
  end

  def user(id, token)
    items = Feed.run(URI.parse("http://digisynd.lighthouseapp.com/users/#{id}.xml?_token=#{token}"))
  end

  def status_for(item)
    status = Status.first(:conditions => ['created_at > ?', item[:created_at]], :order => "created_at asc", :limit => 1)
  end
end