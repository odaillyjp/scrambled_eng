require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  describe 'GET #show' do
    before { get :show }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end
end
