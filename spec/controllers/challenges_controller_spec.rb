require 'rails_helper'

RSpec.describe ChallengesController, type: :controller do
  let(:challenge) { create(:challenge) }

  shared_examples '#fetch_challenges' do
    it '@challengesに作成したchallengeが含まれていること' do
      expect(assigns(:challenges)).to be_include(challenge)
    end
  end

  shared_examples '#fetch_challenge' do
    it '作成したchallengeが取得できていること' do
      expect(assigns(:challenge)).to eq challenge
    end
  end

  describe 'GET #index' do
    before do
      get :index, course_id: challenge.course
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it_behaves_like '#fetch_challenges'
  end

  describe 'GET #show' do
    before do
      get :show, course_id: challenge.course, sequence_number: challenge
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it_behaves_like '#fetch_challenge'
  end

  describe 'POST #resolve' do
    context 'テキストに誤りがあるリクエストだったとき' do
      before do
        post :resolve,
          course_id: challenge.course,
          sequence_number: challenge,
          raw_text: 'foo'
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'correct が false であるデータを返すこと' do
        expect(JSON.parse(response.body)['correct']).to be_falsy
      end
    end

    context 'テキストに誤りがないリクエストだったとき' do
      before do
        post :resolve,
          course_id: challenge.course,
          sequence_number: challenge,
          raw_text: challenge.en_text
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'correct が true であるデータを返すこと' do
        expect(JSON.parse(response.body)['correct']).to be_truthy
      end
    end
  end

  describe 'POST #find_mistake' do
    before do
      post :find_mistake,
        course_id: challenge.course,
        sequence_number: challenge,
        raw_text: 'foo'
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end
end
