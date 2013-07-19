class AppsController < ApplicationController
  def index
    @apps = App.all.order('id DESC')
  end

  def show
    @app = App.find params[:id]
  end
end
