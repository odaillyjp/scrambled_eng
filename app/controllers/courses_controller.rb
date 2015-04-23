class CoursesController < ApplicationController
  before_action :authenticate_user!, only: %i(new edit create update destroy manage)
  before_action :fetch_course, only: %i(show edit update manage)
  before_action :authenticate_access_permittion, only: %i(show)
  before_action :authenticate_management_permittion, only: %i(edit update destroy manage)

  def index
    @courses = Course.only_authorized(current_user)
  end

  def show
  end

  def new
    @course = current_user.courses.new
  end

  def edit
  end

  def create
    @course = current_user.courses.new(course_params)

    if @course.save
      flash[:notice] = I18n.t('activerecord.notices.models.course.create')
      redirect_to :manage
    else
      render action: 'new'
    end
  end

  def update
    if @course.update_attributes(course_params)
      flash[:notice] = I18n.t('activerecord.notices.models.course.update')
      redirect_to management_course_path(@course)
    else
      render action: 'edit'
    end
  end

  def destroy
    Course.find(params[:id]).destroy

    redirect_to root_path
  end

  def manage
  end

  private

  def fetch_course
    @course = Course.find(params[:id])
  end

  def authenticate_access_permittion
    authenticate_permittion do
      case @course.state
      when 'overtness'
        true
      when 'members_only'
        user_sign_in?
      when 'secret'
        @course.user == current_user
      end
    end
  end

  def authenticate_management_permittion
    authenticate_permittion do
      if @course.updatable
        user_sign_in?
      else
        @course.user == current_user
      end
    end
  end

  def course_params
    params.require(:course).permit(:name, :description, :level, :state, :updatable)
  end
end
