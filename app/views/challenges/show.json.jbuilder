json.extract! @challenge, :id, :ja_text, :hidden_text
json.url course_challenge_url(@challenge, course_id: @challenge.course)
