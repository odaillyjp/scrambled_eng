class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @recently_histories = History.where(user: @user)
                            .joins(:challenge)
                            .includes(challenge: :course)
                            .group('challenges.course_id')
                            .limit(5)
    @manageable_courses = Course.where(user: @user)
  end
end
