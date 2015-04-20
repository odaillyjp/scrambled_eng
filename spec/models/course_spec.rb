# == Schema Information
#
# Table name: courses
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  description :text
#  level       :integer          default(0), not null
#  user_id     :integer          not null
#  state       :integer          default(0), not null
#  updatable   :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe Course, type: :model do
  let(:course) { build(:course) }
  subject { course }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_most(40) }
  it { is_expected.to validate_length_of(:description).is_at_most(120) }
  it { is_expected.to validate_presence_of(:level) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:state) }

  context '自分が作った非公開のコースのとき' do
    let(:current_user) { create(:user) }
    let(:course) { create(:course, user: current_user, state: :secret) }

    describe '.only_authorized' do
      context 'そのコースの製作者を渡したとき' do
        it '作ったコースを含んだオブジェクトが返ってくること' do
          expect(Course.only_authorized(current_user)).to be_include(course)
        end
      end

      context 'そのコースの製作者以外を渡したとき' do
        let(:other_user) { create(:user) }

        it '作ったコースが含まれていないこと' do
          expect(Course.only_authorized(other_user)).not_to be_include(course)
        end
      end

      context 'nullを渡したとき' do
        it '作ったコースが含まれていないこと' do
          expect(Course.only_authorized(nil)).not_to be_include(course)
        end
      end
    end
  end

  context '他のユーザーが作った公開されたコースのとき' do
    let(:current_user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:course) { create(:course, user: other_user, state: :overtness) }

    describe '.only_authorized' do
      context 'そのコースの製作者を渡したとき' do
        it '作ったコースを含んだオブジェクトが返ってくること' do
          expect(Course.only_authorized(current_user)).to be_include(course)
        end
      end

      context 'nullを渡したとき' do
        it '作ったコースを含んだオブジェクトが返ってくること' do
          expect(Course.only_authorized(nil)).to be_include(course)
        end
      end
    end
  end
end
