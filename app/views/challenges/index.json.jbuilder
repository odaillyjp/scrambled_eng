json.array!(@challenges) do |challenge|
  json.extract! challenge, :id, :ja_text, :hidden_text
  json.course_name challenge.course.name
  json.url course_challenge_url(challenge, course_id: challenge.course)
end
