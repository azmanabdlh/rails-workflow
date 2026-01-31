class Candidate < ApplicationRecord
  has_many :workflows

  def last_workflow_stage
    workflows.find_by(stage_id: current_stage_id)
  end
end