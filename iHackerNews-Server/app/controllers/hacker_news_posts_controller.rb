class HackerNewsPostsController < ApplicationController

  INCORRECT_PARAMETER_ERROR = "Incorrect parameters passed in"

  def index
  end

  # TODO: think about what do we need to show a hackernews, do we need user_id?
  def show
    if authenticate_show_params
      selected_post = HackerNewsPost.where(:id => params[:post_id]).first
      render :json => {:success => true, :url => selected_post.url}
    else
      render :json => {:success => false, :error => INCORRECT_PARAMETER_ERROR}
    end
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  protected

  def authenticate_show_params
    return params[:post_id] ? false : true
  end

  def authenticate_post_params
    return params[:post_url].nil? || params[:user_id].nil? ? false : true
  end
end
