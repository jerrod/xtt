class UserObserver < ActiveRecord::Observer
  def after_save(user)
    User::Mailer.deliver_activation(user) if user.pending?
  end
end
