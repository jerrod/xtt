# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  cattr_accessor :host_name, :instance_writer => false

  include AuthenticatedSystem
  include ExceptionNotifiable
  helper :all # include all helpers, all the time
  before_filter :set_host
  before_filter :adjust_format_for_iphone
  before_filter :set_timezone

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'b26d74a5338fb7435501904f0451dc26'

  helper_method :iphone_user_agent?, :browser_timezone

protected
  def iphone_user_agent?
    @iphone_user_agent ||= (request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)/]) || :false
    @iphone_user_agent  != :false
  end

  # Set iPhone format if request to iphone.trawlr.com
  def adjust_format_for_iphone    
    request.format = :iphone if iphone_user_agent?
  end
  
  # The browsers give the # of minutes that a local time needs to add to
  # make it UTC, while TimeZone expects offsets in seconds to add to 
  # a UTC to make it local.
  def browser_timezone
    return nil if cookies[:tzoffset].blank?
    @browser_timezone ||= begin
      min = cookies[:tzoffset].to_i
      TimeZone[(min + (-2 * min)).minutes]
    end
  end

  def set_timezone
    if logged_in? && browser_timezone && browser_timezone.name != current_user.time_zone
      current_user.update_attribute(:time_zone, browser_timezone.name)
    end
    Time.zone = logged_in? ? current_user.time_zone : browser_timezone
  end
  
  def set_host
    self.class.host_name = request.host
  end
end
