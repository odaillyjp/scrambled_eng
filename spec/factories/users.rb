FactoryGirl.define do
  factory :user do
    sequence(:uid)
    provider 'google'
    name FFaker::Name.name
    image 'http://example.com/image.jpg'
  end
end
