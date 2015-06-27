class HackerNewsPostsController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:mark_post] 

  INCORRECT_PARAMETER_ERROR = "Incorrect parameters passed in"
  POST_HAS_BEEN_MARKED = "This post has already been marked as favorite"

  def index
    @posts = HackerNewsPost.all
    render :json => {:success => true, :info => @posts.order("created_at DESC")}
  end

  # posts/:id
  def show
    if params[:id]
      selected_post = HackerNewsPost.find(params[:id])
      render :json => {:success => true, :info => selected_post}
    else
      render :json => {:error => INCORRECT_PARAMETER_ERROR}
    end
  end

  def new
  end

  ## create new post && new relation between user and hackernews post ##
  def mark_post
    if authenticate_post_params
      user = User.find_by_id(params[:user_id])
      marked_post = HackerNewsPost.where(:url => params[:post_url], :title => params[:post_title], :urlDomain => params[:post_url_domain]).first
      if marked_post.nil?
        new_starred_post = HackerNewsPost.new :url => params[:post_url], :title => params[:post_title], :urlDomain => params[:post_url_domain]
        if new_starred_post.save
          # new_user_post_relation = UsersHackerNewsPostsJoin.new :user_id => user.id, :post_id => new_starred_post.id
          user.hacker_news_posts << new_starred_post
          render :json => {:success => true }
        else
          render :json => {:error => new_starred_post.errors.full_messages.to_sentence}
        end
      elsif user.hacker_news_posts.include? marked_post
        render :json => {:error => POST_HAS_BEEN_MARKED}
      else
        user.hacker_news_posts << marked_post 
        render :json => {:success => true }
      end
    else
      render :json => {:error => INCORRECT_PARAMETER_ERROR}
    end
  end

  def edit; end

  def update; end

  protected

  def authenticate_post_params
    params[:post_url].nil? || params[:user_id].nil? || params[:post_url_domain].nil? || params[:post_title].nil? ? false : true
  end

end

