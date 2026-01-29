# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

now = Time.current

post = Post.find_or_create_by(
  title: "BE Go Software Engineer",
  body: "example",
  started_at: now,
  ended_at: now + 2.days
)

applied = Stage.find_or_create_by!(
  name: "Applied",
  order: 1,
  post_id: post.id
)

Stage.find_or_create_by!(
  name: "Screening",
  order: 2,
  post_id: post.id

)
Stage.find_or_create_by!(
  name: "Tech Interview",
  order: 3,
  post_id: post.id
)
Stage.find_or_create_by!(
  name: "HR Interview",
  order: 4,
  post_id: post.id
)
Stage.find_or_create_by!(
  name: "Offering",
  order: 5,
  post_id: post.id
)


user = User.find_or_create_by(
  name: "maman",
  email: "maman@example.com"
)

candidate = Candidate.find_or_create_by(
  name: "davina",
  email: "davina@example.com"
)

candidate_stage = CandidateStage.find_or_create_by!(
  candidate_id: candidate.id,
  stage: applied,
  entered_at: now
)


Reviewer.find_or_create_by!(
  candidate_stage_id: candidate_stage.id,
  user_id: user.id
) do |r|

  r.phase = :pending
  r.order = 1
  r.feedback = "example"
end