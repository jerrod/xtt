class Status
  before_save :update_hours_or_finished_at
  after_save  "@update_hours_from_hours = nil"

  def set_hours
    read_attribute :hours
  end
  
  def set_hours=(value)
    @update_hours_from_hours = true
    write_attribute :hours, value
  end
  
  # The accurate amount of time (not rounded) this project has taken.
  def accurate_time
    return if created_at.nil?
    (finished_at || Time.zone.now) - created_at
  end

protected
  def update_hours_or_finished_at
    if @update_hours_from_hours
      self.finished_at = hours.nil? ? nil : created_at + hours.to_f.hours
    else
      self.hours = \
        if followup && followup.project_id && followup.project_id == project_id
          accurate_time / 1.hour.to_f
        else
          (accurate_time.to_f / 15.minutes.to_f).ceil / 4.0
        end
    end
  end
end