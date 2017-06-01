class ServiceProvidersController < ApplicationController
  before_action :set_user
  before_action :set_service_provider, only: [:show, :edit, :update, :destroy, :reset_keys]
  before_action :correct_user, only: [:show, :edit, :update, :destroy]


  def reset_keys
    @service_provider.secret_key = ServiceProvider.new_secret_key
    @service_provider.credential = ServiceProvider.new_credential
    @service_provider.save
    flash[:warning] = "SETCRET_KEY: #{@service_provider.secret_key}   CREDENTIAL: #{@service_provider.credential}"
    render 'show'
  end
  # GET /service_providers
  # GET /service_providers.json
  def index
    @service_providers = ServiceProvider.where(user_id: @user.id)
    flash[:warning] = I18n.t('no_access_right') if @service_providers.size == 0
  end

  # GET /service_providers/1
  # GET /service_providers/1.json
  def show
  end

  # GET /service_providers/new
  def new
    @service_provider = ServiceProvider.new
  end

  # GET /service_providers/1/edit
  def edit
  end

  # POST /service_providers
  # POST /service_providers.json
  def create
    @service_provider = ServiceProvider.new(create_params)

    respond_to do |format|
      if @service_provider.save
        format.html { redirect_to @service_provider, notice: 'Service provider was successfully created.' }
        format.json { render :show, status: :created, location: @service_provider }
      else
        format.html { render :new }
        format.json { render json: @service_provider.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /service_providers/1
  # PATCH/PUT /service_providers/1.json
  def update
    respond_to do |format|
      if @service_provider.update(service_provider_params)
        format.html { redirect_to @service_provider, notice: 'Service provider was successfully updated.' }
        format.json { render :show, status: :ok, location: @service_provider }
      else
        format.html { render :edit }
        format.json { render json: @service_provider.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /service_providers/1
  # DELETE /service_providers/1.json
  def destroy
    @service_provider.destroy
    respond_to do |format|
      format.html { redirect_to service_providers_url, notice: 'Service provider was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_service_provider
      @service_provider = ServiceProvider.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def service_provider_params
      params.require(:service_provider).permit(:app_id, :auth_level, :credential, :secret_key, :description, :callback_url, :revoke_url)
    end

  def create_params
    got = params.require(:service_provider).permit(:app_id, :auth_level, :credential, :secret_key, :description, :callback_url)
    got.merge({user: current_user, secret_key: ServiceProvider.new_secret_key, credential: ServiceProvider.new_credential})
  end

  def set_user
    return @user = current_user if current_user
    flash[:warning] = I18n.t('need_login')
    redirect_to login_path
  end

  def correct_user
    unless @user == @service_provider.user || @user.admin?
      flash[:warning] = I18n.t 'no_access_right'
      redirect_to login_path
    end
  end
end
