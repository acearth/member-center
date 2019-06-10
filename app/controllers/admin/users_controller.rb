class Admin::UsersController < ApplicationController
  before_action :logged_in_user, except: :search
  before_action :correct_user, except: :search

  WillPaginate.per_page = 10

  def search
    render json: {error: "parameter keywords is required"} and return if params[:keywords].blank?
    got = retrieve
    render json: got.map{|u| u.slice(:email, :user_name, :emp_id)}
  end

  def index
    @users = retrieve
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

  private

  def retrieve
    got = []
    if params[:keywords]
      ldap_search_users = LdapService.find_user(params[:keywords]).map do |item|
        User.new(user_name: item.cn.first, email: item.mail.first, role: LdapService.role(item.cn.first))
      end

      ldap_role_users = LdapService.member_list(params[:keywords]).map do |cn|
        email = cn.include?('@') ? cn : LdapService.find_user(cn).first.mail.first
        User.new(user_name: cn, email: email, role: params[:keywords])
      end
      got = ldap_search_users + ldap_role_users
    end
    if params[:keywords] && params[:keywords].size > 0
      sanitized_keywords = params[:keywords]
      sanitized_keywords = sanitized_keywords[0..-2] if sanitized_keywords[-1] == '*'
      sanitized_keywords = sanitized_keywords[1..-1] if sanitized_keywords[0] == '*'
      searched_result = User.search(sanitized_keywords)
      got += searched_result if searched_result
    end
    got.uniq {|u| u.user_name}
  end
end
