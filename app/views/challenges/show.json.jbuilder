json.extract! @challenge, :id, :ja_text, :hide_en_text
json.url course_challenge_url(@challenge, course_id: @challenge.course)
