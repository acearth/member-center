class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :logged_in_user, only: [:edit, :update, :index]
  before_action :correct_user, only: [:edit, :update]

  # GET /users
  # GET /users.json
  def index
    @user = current_user
    redirect_to @user and return unless @user.admin?
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
    if notice&.include?('successfully created')
      @qr_code = RQRCode::QRCode.new(UserSecurity.find_by_user_id(@user.id).render_otp_key, size: 10, level: :h)
    else
      @qr_code = nil
    end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # TODO-proof: Email can not be changed
  # GET /users/1/edi
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    @user.credential = SecureRandom.base58(32)
    @user.role = :inactive
    respond_to do |format|
      if @user.save
        UserMailer.activate(@user, activate_user_url(@user)).deliver_later
        format.html {redirect_to @user, notice: 'User was successfully created. Please check your mailbox.'}
        format.json {render :show, status: :created, location: @user}
      else
        format.html {render :new}
        format.json {render json: @user.errors, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      changeable_params = params.require(:user).permit(:mobile_phone, :emp_id, :password, :password_new)
      if changeable_params[:password_new].present?
        if @user.authenticate(changeable_params[:password])
          changeable_params[:password] = changeable_params.delete :password_new
        else
          flash[:warning] = 'Old password wrong!'
          redirect_to edit_user_path and return
        end
      else
        changeable_params.delete :password
        changeable_params.delete :password_new
      end
      if @user.update(changeable_params)
        format.html {redirect_to @user, notice: 'User was successfully updated.'}
        format.json {render :show, status: :ok, location: @user}
      else
        format.html {render :edit}
        format.json {render json: @user.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html {redirect_to users_url, notice: 'User was successfully destroyed.'}
      format.json {head :no_content}
    end
  end

  def activate
    @user = User.find(params[:id])
    if CommonUtils.valid_email_token?('activate', params[:activate_token], @user)
      @user.role = 0
      @user.save!
      flash[:notice] = 'Your account is activated successfully'
    else
      flash[:warning] = 'Failed to activate user'
    end
    redirect_to login_path
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:user_name, :emp_id, :mobile_phone, :email, :password)
  end

  # Confirms the correct user.
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  # TODO-impl
  def activate_token
    @user.user_name
  end
end
