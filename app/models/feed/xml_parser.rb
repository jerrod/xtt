class Feed
  require 'hpricot'
  
  #acts_as_cached
  
  class << self
    def run(url)
      data, xml = nil, nil
      #begin
      #  data = get_cache(Digest::SHA1.hexdigest(url), :ttl => 5.minutes) do
      
      url = url # 
      #req = Net::HTTP::Get.new(url.path)
      #req.basic_auth options[:token], 'x'
      #logger.warn "Requesting #{url}"
      #req.set_content_type = 'application/xml'
      #return data = `curl #{url}` # Net::HTTP.new(url.host, url.port).read #start {|http| http.request(req) }

      data = Net::HTTP.get(url)
      #  end
      #rescue # bug
      #  # this can fail if the feed blocks us
      #  return nil
      #end
      
      begin
        xml = Hpricot data
      rescue => err # this can fail if there are bad data
        return nil
      end
      
      #data = {
      #  :title    => xml.root.elements['tickets/title'].text,
      #  :home_url => xml.root.elements['channel/link'].text,
      #  :rss_url  => url,
      #  :items    => []
      #}
      data = { :items => [] }

      tickets = xml/'ticket'
      tickets.each do |item|
        number = item/'number'
        title  = item/'title'
        data[:items] << { 
          :number     => (item/'number').inner_html, 
          :title      => (item/'title').inner_html,
          :created_at => Time.parse((item/'created-at').inner_html)
        }
      end
      data[:items]
    end
  
    # def mux(urls)
    #   items = urls.collect { |url| run(url)[:items] }.flatten
    #   items.each do |i| 
    #     begin
    #       i[:pubDate] = i[:pubDate].to_datetime
    #     rescue
    #       i[:pubDate] = nil
    #     end
    #   end
    #   sorted_items = items.sort_by {|i| rand(items.size) }
    #   guids = sorted_items.collect {|i| i[:guid]}.uniq
    #   guids.inject([]) do |arr, guid|
    #     arr << sorted_items.detect {|i| i[:guid] == guid }
    #   end
    # end
  
  end
  
end
