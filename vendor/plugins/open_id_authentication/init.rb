config.gem "ruby-openid", :lib => "openid", :version => "1.1.4"
config.gem "ruby-yadis",  :lib => "yadis",  :version => "0.3.4"

config.after_initialize do
  ActionController::Base.send :include, OpenIdAuthentication
end