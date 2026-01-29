class Candidate < ApplicationRecord

  has_many :candidate_stages

  scope :current_phase, -> { candidate_stages.find_by(stage_id: current_stage_id, exited_at: nil) }
end