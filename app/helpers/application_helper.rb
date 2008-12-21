# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include LiveTimer
  
  def box(type, name, &block)
    type = type.to_s
    box = OpenStruct.new
    box.name= name
    yield box
    render :file => "#{RAILS_ROOT}/app/views/components/#{type}_box.html.erb", :locals => {:box => box}
  end
  
  def gravatar_for(user)
    image_tag "http://www.gravatar.com/avatar.php?gravatar_id=#{MD5.hexdigest user.email}&rating=R&size=48", :alt => h(user.login), :class => 'thumbnail fn'
  end
  
  def first_in_collection?(collection, index)
    collection.size == (index  + 1)
  end
  
  def update_button
    tag(:input, {:type => 'image', :src => '/images/btns/ghost.gif', :class => 'btn', :name => 'submit', :value => 'Update'})
  end
  
  def out_button
    # img_button :out
    %(<input type="submit" name="submit" value="Out" /> (replace with button, please))
  end
  
  def save_button
    img_button :save
  end
  
  def img_button(name)
    tag(:input, {:type => 'image', :src => '/images/btns/ghost.gif', :class => "btn #{name}", :name => 'submit', :value => name.to_s.capitalize})
  end
  
  def link_to_status(status)
    ret = ""
    ret << (status.project ? link_to(h(status.project.name), status.project) + ": " : "Out: ")
    ret << link_to(h(status.message), status)
    ret
  end
  
  def start_time_for(status)
    js_time status.created_at
  end
  
  def finish_time_for(status)
    js_time status.finished_at
  end

  @@default_jstime_format = "%d %b, %Y %I:%M %p"
  def js_datetime(time, rel = :datetime, abbr = false)
    span = content_tag('span', time.utc.strftime(@@default_jstime_format), :class => :timestamp, :rel => rel, :title => time.utc.strftime(@@default_jstime_format))
    return content_tag('abbr', span, :title => time.iso8601, :class => 'published') if abbr
    span
  end
  
  def js_time_ago_in_words(time)
    js_datetime time, :words
  end
  
  def js_time(time)
    js_datetime time, :time
  end
  
  def js_day(time)
    js_datetime time, :day
  end
  
  def js_day_name(time)
    js_datetime time, :dayName
  end
  
  def display_flash(key)
    return nil if flash[key].blank?
    content_tag(:div, content_tag(:div, h(flash[key]), :class => 'mblock-cnt'), :class => 'mblock', :id => key.to_s.downcase)
  end
  
  def number_to_running_time(seconds)
    seconds = seconds.to_i
    is_negative = seconds < 0
    seconds = seconds.abs
    return '0' unless seconds > 0
    hours   = seconds / 1.hour
    seconds = seconds % 1.hour
    minutes = seconds / 1.minute
    seconds = seconds % 1.minute
    (is_negative ? '-' : '') + (hours > 0 ? "#{hours}:" : '') + ('%02d:%02d' % [minutes, seconds])
  end  


  def csv_statuses(ary)
    FasterCSV.generate(:force_quotes => true) do |csv| 
      ary.each do |status|
        csv << [
          status.created_at ? status.created_at.strftime("%Y-%m-%d %H:%M") : nil,
          status.finished_at ? status.finished_at.strftime("%Y-%m-%d %H:%M") : nil,
          (status.project ? "@#{status.project.code} " : "") + h(status.message.to_s.gsub('"', '""'))
        ] 
      end
    end
  end
end
