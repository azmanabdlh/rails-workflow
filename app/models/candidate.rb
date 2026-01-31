class Candidate < ApplicationRecord
  has_many :candidate_stages

  alias_method :workflows, :candidate_stages

  def last_workflow_stage
    workflows.find_by(stage_id: current_stage_id, exited_at: nil)
  end
end