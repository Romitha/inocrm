class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    user ||= User.new # guest user (not logged in)
    if user.has_role? :admin
      can :manage, :all
    elsif user.roles.present?
      cannot :read, :all
      cannot :manage, :all
      user.roles.each do |role|
        role.rpermissions.where(controller_resource: "Organization").each do |rpermission|
          can rpermission.controller_action.to_sym, rpermission.controller_resource.constantize, id: user.organization.id
        end

        role.rpermissions.where(controller_resource: "User").each do |rpermission|
          can rpermission.controller_action.to_sym, rpermission.controller_resource.constantize if (user.organization && user.organization.user_ids.include?(user.id))#, id: user.id, organization: {user_ids: user.organization.user_ids} 
          # , User.organization do |block_user|
          #   puts user.inspect
          #   block_user.organization.user_ids.include?(user.id)# if block_user.organization
          # end
        end
      end
    else
      can :read, Organization
    end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
    # aliasing
    # alias_action :create, :read, :update, :destroy, :to => :crud
    # can :crud, User
    # can :invite, User
  end
end
