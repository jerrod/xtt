class << ActiveRecord::Base
  def concerns(*values)
    values.each { |c| require_dependency "#{name.underscore}/#{c}" }
  end
end