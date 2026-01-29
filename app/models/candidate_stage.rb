class CandidateStage < ApplicationRecord
  belongs_to :candidate
  belongs_to :stage

  has_many :reviewers


  def can_transition_stage?(stage_id)
    unless outcome?
      (stage.order + 1) == Stage.find(stage_id).order
    end

    false
  end

  def outcome?
    reviewers.filter { |r| r if r.hired? }.present?
  end

end
