class CandidateController < ApplicationController

  def new
    req = params.permit(:candidate_id, :stage_id)

    from = Candidate.find(req[:candidate_id]).current_phase
    to = Stage.find(req[:stage_id])

    unless from.can_transition_to?(to)
      redirect_to root_path, alert: "invalid stage transition"
    end


    from.reconcile(to) if from.stage_id != to.stage_id

    # update reviewers

  end

end
