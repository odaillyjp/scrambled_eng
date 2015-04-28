require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }

  describe 'GET #show' do
    before { get :show, id: user.id }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end
end
