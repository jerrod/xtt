module Status::Methods
  def self.included(base)
    base.has_many :statuses, :order => 'statuses.created_at desc', :extend => Status::Methods::AssociationExtension
  end
  
  # todo
  def hours
    statuses.sum :hours
  end
  
  module AssociationExtension
    def latest
      @latest ||= first
    end
    
    def after(status)
      find(:first, :conditions => ['statuses.created_at > ?', status.created_at], :order => 'statuses.created_at')
    end
    
    def before(status)
      find(:first, :conditions => ['statuses.created_at < ?', status.created_at], :order => 'statuses.created_at desc')
    end
    
    def sum_accurate_time
      find(:all).sum { |s| s.accurate_time }
    end
  end
end