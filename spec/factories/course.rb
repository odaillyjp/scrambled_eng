FactoryGirl.define do
  factory :course do
    name        Faker::Lorem.word
    description Faker::Lorem.sentence
    level       1
    user
    state       :overtness
    updatable   false
  end
end
