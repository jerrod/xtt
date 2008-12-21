module UsersHelper
  def link_to_user(user, text = nil, url_for_options = nil)
    link_to h(text || user.login), url_for_options || user
  end
end