Quorum = Struct.new(
  :min_reviewers,
  :min_lead_reviewers
) do
  def self.from_json(raw_json)
    return new(min_reviewers: 0, min_lead_reviewers: 0) if raw_json.blank?

    body = JSON.parse(raw_json)
    new(
      min_reviewers: body[:min_reviewers] || 0,
      min_lead_reviewers: body[:min_lead_reviewers] || 0
    )
  end
end


class WorkflowPolicy < ApplicationRecord
  belongs_to :workflow

  after_initialize :parsed_quorum

  validates :quorum, presence: true
  validate :quorum_must_be_valid_json

  def parsed_quorum
    quorum ||= Quorum.from_json(quorum)
  end

  private
  def quorum_must_be_valid_json
    return if quorum.blank?

    JSON.parse(quorum)
  rescue JSON::ParserError
    errors.add(:quorum, "must be valid JSON")
  end
end
