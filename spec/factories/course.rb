FactoryGirl.define do
  factory :course do
    name        FFaker::Lorem.word
    description FFaker::Lorem.sentence
    level       1
    user
    state       :overtness
    updatable   false
  end
end
