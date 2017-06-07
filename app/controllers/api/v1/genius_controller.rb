class Api::V1::GeniusController < ApplicationController

  def login
    render json: {status: 0, msg: :login_sample}
  end

  def authenticate
    render json: {status: 0, msg: :authentication_sample}
  end

  def bonjour
    logger.info 'BONJOUR...' +Time.now.to_s
    render json: {status: 0, msg: :bonjour}
  end
end
