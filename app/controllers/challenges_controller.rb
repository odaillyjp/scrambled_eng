class ChallengesController < ApplicationController
  before_action :fetch_challenges, only: %i(index create resolve)

  def index
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
    @challenge = @challenges.new(challenge_params)

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
    @challenge = @challenges.find(params[:id])
    raw_text = params[:raw_text] || ''

    if @challenge.correct?(raw_text)
      next_challenge = @challenges.order_course_at(@challenge).next
      if next_challenge
        next_challenge_url = course_challenge_url(next_challenge, course_id: params[:course_id])
      end

      render json: {
        correct: true,
        challenge: @challenge,
        next_challenge_url: next_challenge_url,
        course_information_url: course_url(@challenge.course_id)
      }
    else
      mistake = @challenge.teach_mistake(raw_text)
      render json: { correct: false, mistake: mistake }
    end
  end

  private

  def fetch_challenges
    @challenges = Course.find(params[:course_id]).challenges
  end

  def challenge_params
    params.require(:challenge).permit(:en_text, :ja_text)
  end
end
