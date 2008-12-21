class User
  attr_readonly :last_status_project_id, :last_status_id, :last_status_message
  belongs_to :last_status_project, :class_name => "Project"
  belongs_to :last_status, :class_name => "Status"

  has_many :statuses, :order => 'statuses.created_at desc', :extend => Status::Methods::AssociationExtension do
    def filter(filter = :weekly, options = {})
      Status.filter proxy_owner.id, filter, options
    end

    def filtered_hours(filter = :weekly, options = {})
      Status.filtered_hours proxy_owner.id, filter, options
    end

    def hours(filter = :weekly, options = {})
      Status.hours proxy_owner.id, filter, options
    end
  end

  def post(message, source = 'the web')
    statuses.create :code_and_message => message, :source => source
  end

  def backup_statuses!
    t = (Time.now.to_i >> 6).to_s
    FileUtils.mkdir_p(File.join(RAILS_ROOT, "backups", t))
    File.open(File.join(RAILS_ROOT, "backups", t, login + ".xml"), "w+") do |f|
      # because we assume you're an idiot
      f.write statuses.to_xml
    end
  end


protected
  def can_access_status?(status)
    status.project_id.nil? ||
      status.user_id == id ||
      accessible_project_id?(status.project_id)
  end
end