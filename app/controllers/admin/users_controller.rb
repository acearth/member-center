class Admin::UsersController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user

  WillPaginate.per_page = 10
  
  def index
    @users = []
    @users = User.search(params[:keywords]) if params[:keywords]
    render 'users/index'
  end

  def role
    @users = params.select {|k, _| k.to_s.start_with?('user_')}.values
                 .map {|user_name| User.find_by_user_name(user_name)}
    @users.each do |user|
      user.role = params[:new_role]
      user.save
      LdapService.attach_role(params[:new_role], user.user_name)
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
