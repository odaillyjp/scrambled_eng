json.id @challenge.sequence_number
json.extract! @challenge, :ja_text, :cloze_text
json.words @challenge.words.sort if params[:require_words]
json.correct_text @challenge.en_text if params[:require_correct_text]
json.course_name @course.name
json.url course_challenge_url(@challenge, course_id: @challenge.course_id)
