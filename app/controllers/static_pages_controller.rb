class StaticPagesController < ApplicationController
  def home
    @sp_list = ServiceProvider.all
  end

  def help
  end

  def contact
  end
end
