json.array!(@challenges) do |challenge|
  json.id challenge.sequence_number
  json.extract! challenge, :ja_text, :cloze_text, :course_name, :course_description, :course_level
  json.url course_challenge_url(challenge, course_id: challenge.course_id)
end
