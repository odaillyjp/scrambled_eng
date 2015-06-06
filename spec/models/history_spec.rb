require 'rails_helper'

RSpec.describe History, type: :model do
  let(:history) { build(:history) }
  subject { history }

  it { is_expected.to validate_presence_of(:challenge_id) }
  it { is_expected.to be_valid }

  describe '.create' do
    it '#create_with_unix_timestampが呼び出されること' do
      expect_any_instance_of(History).to receive(:create_with_unix_timestamp)
      create(:history, unix_timestamp: Time.current.to_i)
    end
  end

  describe '#create_with_unix_timestamp' do
    it 'unix_timestampに今日の日付でのUnix時間が入っていること' do
      history.send(:create_with_unix_timestamp)
      current_day_unix_time = Time.current.beginning_of_day.to_i
      expect(history.unix_timestamp).to eq current_day_unix_time
    end
  end
end
