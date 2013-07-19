class ReviewsController < ApplicationController
  def index
    @reviews = Review.all.order('id DESC')
  end

  def show
    @review = Review.find params[:id]
  end
end
