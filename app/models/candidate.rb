class Candidate < ApplicationRecord

  has_many :candidate_stages

  def latest_stage_for(post_id)
    candidate_stages.where(post_id: post_id, exited_at: nil).order_by(:order, :desc).first
  end
end