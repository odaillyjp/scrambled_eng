class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @histories = History.where(user: @user)
                   .joins(:challenge)
                   .includes(challenge: :course)
                   .group('challenges.course_id')
                   .limit(5)
  end
end
