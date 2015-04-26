class ChallengesController < ApplicationController
  before_action :authenticate_user!, only: %i(new edit create update destroy)
  before_action :fetch_course
  before_action :fetch_challenges, only: %i(index new create resolve)
  before_action :fetch_challenge,  only: %i(show edit update destroy resolve teach_partial_answer)
  before_action :authenticate_access_permission, only: %i(index show)
  before_action :authenticate_management_permission, only: %i(new edit create update destroy manage)

  def index
  end

  def show
  end

  def new
    @challenge = @challenges.new
  end

  def edit
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
    Challenge.transaction do
      @challenge.destroy!
      challenges = Challenge.where(
        'course_id = ? AND sequence_number > ?',
        params[:course_id],
        params[:sequence_number])
      challenges.update_all('sequence_number = sequence_number - 1')
    end

    flash[:notice] = I18n.t('activerecord.notices.models.challenge.destroy')
    redirect_to management_course_path(@challenge.course)
  end

  def resolve
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
    @history = if user_sign_in?
                 # ユーザー1人あたり、1つの問題につき1日1回しか履歴を作らない
                 History.where('updated_at >= ?', Time.current.beginning_of_day)
                   .find_or_initialize_by(user: current_user, challenge: @challenge)
               else
                 # ログインしていないユーザーの場合、何度でも新しい履歴を作れる
                 History.new(user: nil, challenge: @challenge)
               end

    @history.save!
  end

  def fetch_course
    @course = Course.find(params[:course_id])
  end

  def fetch_challenges
    @challenges = Challenge.where(course_id: params[:course_id])
  end

  def fetch_challenge
    @challenge = Challenge.find_by!(
      course_id: params[:course_id],
      sequence_number: params[:sequence_number])
  end

  def authenticate_access_permission
    authenticate_permission do
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

  def authenticate_management_permission
    authenticate_permission { @course.user == current_user }
  end

  def challenge_params
    params.require(:challenge).permit(:en_text, :ja_text)
  end
end
