class CandidateController < ApplicationController

  def new
    req = candidate_params

    from = Candidate.find(req[:candidate_id]).latest_stage_for(req[:post_id])
    to = Stage.find(req[:stage_id])

    if from.can_transition_to?(to)
      from.decide_by!(Current.session.user, req[:phase], feedback: req[:feedback])
      from.reconcile(to) if from.stage_id != to.stage_id

      render json: {  message: "success" }, status: :ok
    end

    render json: { message: "error stage transition" }, status: :bad_request
  end

  def candidate_params
    params.permit(:phase, :candidate_id, :stage_id, :feedback, :post_id)
  end

end
