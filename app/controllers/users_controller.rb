class UsersController < ApplicationController
  before_action :fetch_user
  before_action :check_forbidden, only: %i(destroy)

  def show
    @recently_played_courses = Course.joins(:challenges)
                                 .joins(challenges: :histories)
                                 .where('histories.user_id = ?', @user)
                                 .limit(5)
    @manageable_courses = Course.where(user: @user)
  end

  def destroy
    @user.destroy
    session[:user_id] = nil
    redirect_to root_path
  end

  private

  def fetch_user
    @user = User.find(params[:id])
  end

  def check_forbidden
    render status: 403 unless @user == current_user
  end
end
