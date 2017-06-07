class Api::V1::GeniusController < ApplicationController

  def login
    render json: {status: 0, msg: :login_sample}
  end

  def authenticate
    render json: {status: 0, msg: :authentication_sample}
  end
end
