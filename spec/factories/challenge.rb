FactoryGirl.define do
  factory :challenge do
    en_text 'She sells seashells by the seashore.'
    ja_text '彼女は海岸で貝殻を売ります。'
    course
    sequence(:sequence_number) { |n| n }
    user
  end
end
