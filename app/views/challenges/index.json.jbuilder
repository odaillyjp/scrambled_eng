json.array!(@challenges) do |challenge|
  json.id challenge.sequence_number
  json.extract! challenge, :ja_text, :cloze_text
  json.course_name @course.name
  json.course_level @course.level
  json.course_description @course.description
  json.url course_challenge_url(challenge, course_id: challenge.course_id)
end
