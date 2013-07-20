class ReviewsController < ApplicationController
  def index
    @reviews = Review.all.includes(:reviewer, apps: :primary_category).order('id DESC').page params[:page]
  end

  def show
    @review = Review.find params[:id]
  end
end
