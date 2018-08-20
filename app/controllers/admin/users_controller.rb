class Admin::UsersController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user

  WillPaginate.per_page = 10
  
  def index
    @users = []
    if params[:keywords]
      ldap_result = LdapService.find_user(params[:keywords])
      if ldap_result.size > 0
        ldap_email = ldap_result.first[:mail].first
        @users = [User.new(user_name: ldap_email, email: ldap_email, role: LdapService.role(user_name) || 'ordinary')]
      end
      @users += User.search(params[:keywords])
    end
    @users.reject! {|user| user.role == 'inactive'}
    render 'users/index'
  end

  def role
    @users = params.select {|k, _| k.to_s.start_with?('user::')}.values
    @users = @users.map {|user_name| User.find_by_user_name(user_name) || User.new(user_name: user_name, email: user_name, role: LdapService.role(user_name) || 'ordinary')}
    @users.each do |user|
      if user
        user.role = params[:new_role]
        user.save if user.id
      end
      LdapService.set_role(params[:new_role], user.user_name)
    end
    render 'users/index'
  end

  def correct_user
    unless current_user.admin?
      flash[:warning] = 'Current user is NOT administrator'
      redirect_to login_path
    else
      flash[:notice] = "admin: #{current_user.user_name}"
    end
  end
end
