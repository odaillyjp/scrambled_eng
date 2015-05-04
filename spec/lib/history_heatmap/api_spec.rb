require 'rails_helper'

module HistoryHeatmap
  RSpec.describe API do
    let(:course) { create(:course) }
    let(:challenge) { create(:challenge, course: course) }
    let(:user) { create(:user) }
    let(:unix_timestamp) { Time.current.to_i }

    before do
      create(:history, challenge: challenge, unix_timestamp: unix_timestamp)
      create(:history, user: user, unix_timestamp: unix_timestamp)
    end

    describe 'get' do
      context 'with course_id, from, to' do
        it '{ UNIX時間 => 件数 }の形式で該当のコースの挑戦履歴を返すこと' do
          hash = API.get(course_id: course, from: 1.month.ago, to: 1.month.since)
          expect(hash).to eq(unix_timestamp => 1)
        end
      end

      context 'with user_id, from, to' do
        it '{ UNIX時間 => 件数 }の形式で該当のユーザーの挑戦履歴を返すこと' do
          hash = API.get(user_id: user, from: 1.month.ago, to: 1.month.since)
          expect(hash).to eq(unix_timestamp => 1)
        end
      end
    end
  end
end
