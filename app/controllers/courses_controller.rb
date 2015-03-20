class CoursesController < ApplicationController
  def index
    @courses = Course.all
  end

  def show
    @course = Course.find(params[:id])
  end

  def new
    @course = Course.new
  end

  def edit
    @course = Course.find(params[:id])
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
      redirect_to @course, notice: 'User was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    Course.find(params[:id]).destroy

    redirect_to root_path
  end

  def manage
    @course = Course.find(params[:id])
  end

  private

  def course_params
    params.require(:course).permit(:name)
  end
end
