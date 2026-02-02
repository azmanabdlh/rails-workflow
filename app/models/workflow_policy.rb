class WorkflowPolicy < ApplicationRecord
  belongs_to :workflow

  validates :quorum_raw, presence: true
  validate :quorum_must_be_valid_json

  enum :action_phase, {
    cancelled: 2,
    passed: 3
  }

  def quorum
    Quorum.from_json(quorum_raw)
  end

  private
  def quorum_must_be_valid_json
    return if quorum_raw.blank?

    JSON.parse(quorum_raw)
  rescue JSON::ParserError
    errors.add(:quorum_raw, "must be valid JSON")
  end
end
