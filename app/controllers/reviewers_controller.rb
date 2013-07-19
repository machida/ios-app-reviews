class ReviewersController < ApplicationController
  def index
    @reviewers = Reviewer.all.order(:id)
  end

  def show
    @reviewer = Reviewer.find params[:id]
  end
end
