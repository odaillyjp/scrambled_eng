class CoursesController < ApplicationController
  before_action :fetch_course, only: %i(show edit update manage)

  def index
    @courses = Course.all
  end

  def show
  end

  def new
    @course = Course.new
  end

  def edit
  end

  def create
    @course = Course.new(course_params)

    if @course.save
      redirect_to @course, notice: 'Course was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @course.update_attributes(course_params)
      redirect_to management_course_path(@course), notice: 'User was successfully updated.'
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

  def course_params
    params.require(:course).permit(:name)
  end
end
