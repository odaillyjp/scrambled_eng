class ChallengesController < ApplicationController
  before_action :authenticate_user!, only: %i(new edit create update destroy)
  before_action :fetch_challenges, only: %i(index create resolve)
  before_action :fetch_challenge,  only: %i(show edit update destroy teach_partial_answer)

  def index
  end

  def show
  end

  def new
    @challenge = Challenge.new(course_id: params[:course_id])
  end

  def edit
    @challenge = Challenge.find_by!(
      course_id: params[:course_id],
      sequence_number: params[:sequence_number])
  end

  def create
    @challenge = @challenges.new(challenge_params)
    @challenge.sequence_number = @challenges.count + 1
    @challenge.user = current_user

    if @challenge.save
      flash[:notice] = I18n.t('activerecord.notices.models.challenge.create')
      redirect_to management_course_path(@challenge.course)
    else
      render action: 'new'
    end
  end

  def update
    if @challenge.update_attributes(challenge_params)
      flash[:notice] = I18n.t('activerecord.notices.models.challenge.update')
      redirect_to management_course_path(@challenge.course)
    else
      render action: 'edit'
    end
  end

  def destroy
    redirect_to root_path
  end

  def resolve
    @challenge = @challenges.find_by!(sequence_number: params[:sequence_number])
    raw_text = params[:raw_text] || ''
    @answer = @challenge.build_answer(raw_text)

    if @answer.check!
      next_challenge = @challenges.order_course_at(@challenge).next(false)

      if next_challenge
        next_challenge_url = course_challenge_url(next_challenge, course_id: params[:course_id])
      end

      create_history!

      render json: {
        correct: true,
        challenge: @challenge,
        next_challenge_url: next_challenge_url,
        course_information_url: course_url(@challenge.course_id)
      }
    else
      render json: { correct: false, mistake: @answer.mistake }
    end
  end

  def teach_partial_answer
    raw_text = params[:raw_text] || ''
    answer = @challenge.build_answer(raw_text)
    answer.detect_partial_answer!
    render json: { mistake: answer.mistake }
  end

  private

  def create_history!
    return false unless user_sign_in?

    # 1つの問題につき、1日に1回しか履歴を作らない
    @history = History.where('updated_at >= ?', Time.current.beginning_of_day)
      .find_or_initialize_by(user: current_user, challenge: @challenge)

    @history.save!
  end

  def fetch_challenges
    @challenges = Course.find(params[:course_id]).challenges
  end

  def fetch_challenge
    @challenge = Challenge.find_by!(
      course_id: params[:course_id],
      sequence_number: params[:sequence_number])
  end

  def challenge_params
    params.require(:challenge).permit(:en_text, :ja_text)
  end
end
