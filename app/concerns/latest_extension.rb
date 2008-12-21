module LatestExtension
  def latest
    @__latest__ = (first || false) unless @__latest__ == false
  end
end