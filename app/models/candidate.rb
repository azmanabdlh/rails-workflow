class Candidate < ApplicationRecord
  has_many :candidate_stages

  delegate :stages, to: :candidate_stages

  def last_workflow_stage
    stages.find_by(stage_id: current_stage_id, exited_at: nil)
  end
end