json.array!(@challenges) do |challenge|
  json.id challenge.sequence_number
  json.extract! challenge, :ja_text, :hidden_text
  json.course_name challenge.course.name
  json.url course_challenge_url(challenge, course_id: challenge.course)
end
