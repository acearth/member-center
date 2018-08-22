class Admin::UsersController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user

  WillPaginate.per_page = 10
  
  def index
    @users = []
    if params[:keywords]
      ldap_search_users = LdapService.find_user(params[:keywords]).map do |item|
        User.new(user_name: item.cn.first, email: item.mail.first, role: LdapService.role(item.cn.first))
      end

      ldap_role_users = LdapService.member_list(params[:keywords]).map do |cn|
        email = cn.include?('@') ? cn : LdapService.find_user(cn).first.mail.first
        User.new(user_name: cn, email: email, role: params[:keywords])
      end
      @users = ldap_search_users + ldap_role_users
    end
    searched_result = User.search(params[:keywords])
    @users += searched_result if searched_result
    @users.uniq! {|u| u.user_name}
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
