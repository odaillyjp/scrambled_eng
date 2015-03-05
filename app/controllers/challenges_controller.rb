class ChallengesController < ApplicationController
  def index
    @challenges = Course.find(params[:course_id]).challenges
  end

  def show
    @challenge = Challenge.find(params[:id])
  end

  def new
    @challenge = Challenge.new
  end

  def edit
    @challenge = Challenge.find(params[:id])
  end

  def create
    course = Course.find(params[:course_id])
    @challenge = course.challenges.new(challenge_params)

    if @challenge.save
      redirect_to course, notice: 'Challenge was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @challenge.update_attributes(challenge_params)
      redirect_to @challenge, notice: 'Challenge was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    challenge.find(params[:id]).destroy

    redirect_to root_path
  end

  def resolve
    @challenge = Challenge.find(params[:id])
    raw_text = params[:raw_text] || ''

    if @challenge.correct?(raw_text)
      render json: { correct: true }
    else
      mistake = @challenge.teach_mistake(raw_text)
      render json: { correct: false, mistake: mistake }
    end
  end

  private

  def challenge_params
    params.require(:challenge).permit(:en_text, :ja_text)
  end
end
