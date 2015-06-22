class UsersController < ApplicationController

  #remove this line if can this application also needs to run as a browser Application 
  #currently works because this only serves as an API for the iOS app.
  skip_before_filter :verify_authenticity_token, :only => [:create] 

  INCORRECT_PARAMETER_ERROR = "Incorrect parameters passed in"
  INVALID_FACEBOOK_USER_ERROR = "Invalid facebook user"
  INVALID_USER_ERROR = "Invalid username or password"
  DUPLICATE_USER_ERROR = "User already exists"
  INCOMPELETE_CREATION_FORM_ERROR = "Form for creating new user is incomplete"

  def index
  end

  #GET /users/id?(.:format)
  def show
    if authenticate_params_and_tell_user_identity == 0
      get_facebook_user
    elsif authenticate_params_and_tell_user_identity == 1
      get_normal_user
    end
  end

  def new; end

  #POST /users(.:format)
  def create
    if authenticate_params_and_tell_user_identity == 0
      if verify_facbeook_user_exists
        render :json => {:error => DUPLICATE_USER_ERROR}
      else
        create_fb_user
      end
    elsif authenticate_params_and_tell_user_identity == 1
      if verify_normal_user_exists
        render :json => {:error => DUPLICATE_USER_ERROR}
      else
        create_normal_user
      end
    end
  end

  def edit; end

  def update; end

  def destroy; end

  # this gives back all starred posts of a specific user
  def posts_of_user
    identity = authenticate_params_and_tell_user_identity
    if identity == 1
      user = params[:user_email].nil? ? User.where(:username => params[:username], :password => params[:password]).first : User.where(:email => params[:user_email], :password => params[:password]).first
      render :json => {:success => true, :info => User.posts_of_user(user).order("created_at DESC") }
    elsif identity == 0
      # TODO: deal with facebook user
    end
  end

  protected

  ## authenticate passed in parameters and render user info ##

  ## 0 -- facebook user, 1 -- normal user
  def authenticate_params_and_tell_user_identity
    if !params[:facebook_id].nil? && !params[:facebook_auth_token].nil?
      return 0
    elsif !params[:username].nil? && !params[:password].nil? || !params[:user_email].nil? && !params[:password].nil? 
      return 1
    else
      render :json => {:error => INCORRECT_PARAMETER_ERROR}
    end
  end

  def get_facebook_user
    fb_user = User.where(:facebook_id => params[:facebook_id]).first
    if !fb_user.nil?
      render :json => {:success => true, :user_info => {:user_id => fb_user.id, :facebook_id => fb_user.facebook_id}}
    else
      render :json => {:error => INVALID_FACEBOOK_USER_ERROR}
    end
  end

  def get_normal_user 
    existing_user = User.where(:username => params[:username], :password => params[:password]).first || User.where(:email => params[:user_email], :password => params[:password]).first
    if !existing_user.nil?
      render :json => {:success => true, :user_info => {:user_id => existing_user.id, :username => existing_user.username, :profile_picture_url => existing_user.profile_picture_url, :email => existing_user.email}}
    else
      render :json => {:error => INVALID_USER_ERROR}
    end
  end

  ## verify user's existence ##
  
  def verify_normal_user_exists
    existing_user = User.where(:username => params[:username])
    return !existing_user.empty?
  end

  def verify_facbeook_user_exists
    fb_user = User.where(:facbeook_id => params[:facebook_id])
    return !fb_user.empty?
  end


  ## create user form ##
  #

  def check_normal_user_creation_form
    if params[:username].nil? || params[:password].nil? || params[:user_email].nil?
      return false
    else
      return true
    end
  end
  
  def create_normal_user
    if check_normal_user_creation_form
      new_user = User.new :username => params[:username], :password => params[:password], :email => params[:user_email]
      if new_user.save
        get_normal_user
      else
        render :json => {:error => new_user.errors.full_messages.to_sentence}
      end
    else
      render :json => {:error => INCOMPELETE_CREATION_FORM_ERROR}
    end
  end

  def create_fb_user
    new_user = User.new :facebook_id => params[:username]
    if new_user.save
      get_facebook_user
    else
      render :json => {:error => new_user.errors.full_messages.to_sentence}
    end
  end

end
