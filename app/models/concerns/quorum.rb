Quorum = Struct.new(
  :min_reviewers,
  :min_lead_reviewers
) do
  def self.from_json(raw_json)
    return new(min_reviewers: 0, min_lead_reviewers: 0) if raw_json.blank?

    body = JSON.parse(raw_json)

    new(
      min_reviewers: body["min_reviewers"] || 0,
      min_lead_reviewers: body["min_lead_reviewers"] || 0
    )
  end
end