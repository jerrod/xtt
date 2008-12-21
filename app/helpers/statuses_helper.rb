module StatusesHelper
  def status_summary(project)
    return 'is out' if project.nil?
    current_user.can_access?(project) ? "is working on #{h(project.name)}" : "is busy"
  end
  
  def status_for(user_or_status)
    message = user_or_status.is_a?(User) ? user_or_status.last_status_message : user_or_status.message
    if message.blank?
      'No update'
    elsif current_user.can_access?(user_or_status)
      h(message)
    else
      'Busy'
    end
  end
  
  def status_at(status_or_date)
    created_at = case status_or_date
      when User   then status_or_date.last_status_at
      when Status then status_or_date.created_at
      else status_or_date
    end
    created_at && "#{js_time_ago_in_words created_at}"
  end

  def link_to_filtered_statuses(text, options = {})
    link_to text, url_for_filtered_statuses(options)
  end
  
  # :user_id
  # :filter
  # :date
  # :project
  def url_for_filtered_statuses(options = {})
    user_id = options.key?(:user_id) ? options[:user_id] : params[:user_id]
    filter  = options.key?(:filter)  ? options[:filter]  : params[:filter]
    args    = {:date => options.key?(:date) ? options[:date] : params[:date]}
    prefix, args  = filter.blank? ? [nil, args] : ["filtered_", args.update(:filter => filter)]
    url = 
      if options.key?(:project) || controller.controller_name == 'projects'
        args[:id] ||= options[:project] || params[:id]
        case user_id
          when nil, :all then send("#{prefix}project_for_all_path",  args)
          when :me       then send("#{prefix}project_for_me_path",   args.update(:user_id => :me))
          else                send("#{prefix}project_for_user_path", args.update(:user_id => user_id))
        end
      elsif options.key?(:context) || controller.controller_name == 'contexts'
        args[:id] ||= options[:context] || params[:id]
        case user_id
          when nil, :all then send("#{prefix}context_for_all_path",  args)
          when :me       then send("#{prefix}context_for_me_path",   args.update(:user_id => :me))
          else                send("#{prefix}context_for_user_path", args.update(:user_id => user_id))
        end
      else
        send("#{prefix}user_path", args)
      end
  end

  def chart_labels_for(filter, date_range)
    filter = filter.to_sym if filter
    case filter
      when :weekly then %w(Mon Tue Wed Thu Fri Sat Sun)
      when :monthly, :'bi-weekly' then 
        first, last = date_range.first.day, date_range.last.day
        if last > first # end date in same month
          (first..last).to_a
        else # end date is next month, standard range won't work here, sonny
          days = ((date_range.last.midnight - date_range.first.midnight) / 1.day).round - last
          (first..first + days).to_a.push *(1..last).to_a
        end
      else raise "Invalid filter: #{filter.inspect}"
    end
  end
  
  def chart_data_for(labels, filter, hours)
    filter     = filter.to_sym if filter
    hour_block = case filter
      when :weekly
        lambda { |memo, (user_id, date, hours)| memo.update(date.strftime("%A")[0..2] => hours) }
      when :monthly, :'bi-weekly'
        lambda { |memo, (user_id, date, hours)| memo.update(date.day => hours) }
    end
    hour_cache = hours.inject({}, &hour_block)
    labels.inject([]) { |memo, day| memo << hour_cache[day].to_f }
  end

  def paging_for_period(date_range)
    return if date_range.nil?
    now = Time.zone.now
    start_date = date_range.first
    prev_date, next_date = nil, nil
    filter = params[:filter].to_sym if params.key?(:filter)
    case filter
      when :daily
        prev_date = start_date - 1.day
        next_date = start_date + 1.day if now > date_range.last
      when :weekly
        prev_date = start_date - 1.week
        next_date = start_date + 1.week if now > date_range.last
      when :'bi-weekly'
        prev_date = start_date.day == 1 ? (start_date - 1.day).beginning_of_month + 14.days : start_date.beginning_of_month
        next_date = start_date.day == 1 ? start_date + 14.days : (start_date + 1.month).beginning_of_month if now > date_range.last
      when :monthly
        prev_date = start_date - 1.month
        next_date = start_date + 1.month if now > date_range.last
    end
    %(<span class="paging">
        #{link_to_filtered_statuses('&larr; previous', :date => prev_date.strftime("%Y-%m-%d")) if prev_date}
        #{link_to_filtered_statuses('next &rarr;', :date => next_date.strftime("%Y-%m-%d")) if next_date}
      </span>)
  end
end
