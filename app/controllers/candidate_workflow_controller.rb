class CandidateWorkflowController < ApplicationController
  def decide
    req = params.permit(:phase, :candidate_id, :stage_id, :feedback)

    from = Candidate
      .find(req[:candidate_id])
      .last_workflow_stage
    to = Stage.find(req[:stage_id])

    unless from.can_transition_to?(to)
      return render json: { message: "invalid stage transition" }, status: :bad_request
    end

    begin
      from.decide_by!(
        resume_session,
        req[:phase],
        feedback: req[:feedback]
      )

      from.reconcile(to) if from.passed?
    rescue => e
      return render json: { message: e.message }, status: :bad_request
    end

    render json: {  message: "success" }, status: :ok
  end
end
