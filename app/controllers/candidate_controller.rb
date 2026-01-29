class CandidateController < ApplicationController

  def phase
    req = params.permit(:phase, :candidate_id, :stage_id, :feedback)

    from = Candidate
      .find(req[:candidate_id])
      .latest_stage
    to = Stage.find(req[:stage_id])

    unless from.can_transition_to?(to)
      return render json: { message: "error stage transition" }, status: :bad_request
    end

    begin
      from.decide_by!(
        1,
        req[:phase],
        feedback: req[:feedback]
      )

      from.reconcile(to) if from.reviewed?

    rescue => e
      return render json: { message: e.message }, status: :bad_request
    end

    render json: {  message: "success" }, status: :ok
  end

end
