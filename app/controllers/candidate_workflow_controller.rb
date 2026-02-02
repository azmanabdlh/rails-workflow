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
      action_phase = req[:phase]

      from.decide_by!(
        resume_session,
        action_phase,
        feedback: req[:feedback]
      )

      from.reconcile(to) if from.reviewed?(action_phase)

      render json: {  message: "success" }, status: :ok
    rescue => e
      render json: { message: e.message }, status: :bad_request
    end
  end
end
