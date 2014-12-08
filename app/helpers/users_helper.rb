module UsersHelper
  def current_user_assigned_role
    role = current_user.roles.find_by_id current_user.current_user_role_id
    yield role
  end
end
