class ReviewsController < ApplicationController
  def index
    @reviews = Review.all.includes(:reviewer, apps: :primary_category).order('id DESC')
  end

  def show
    @review = Review.find params[:id]
  end
end
