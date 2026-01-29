class CandidateController < ApplicationController

  def new
    req = candidate_params
    user = Current.session.user


    candidate = Candidate.find(req[:candidate_id]).current_phase
    to = Stage.find(req[:stage_id])

    unless candidate.can_transition_to?(to)
      redirect_to root_path, alert: "invalid stage transition"
    end

    candidate.decide_by!(user, req[:phase], feedback: req[:feedback])
    candidate.reconcile(to) if candidate.stage_id != to.stage_id
  end

  def candidate_params
    params.permit(:phase, :candidate_id, :stage_id, :feedback)
  end

end
