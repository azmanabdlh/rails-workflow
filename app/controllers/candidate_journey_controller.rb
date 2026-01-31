class CandidateJourneyController < ApplicationController

  def show
    begin
      data = new_schema(
        Candidate.find(
          params[:candidate_id]
        )
      )
      render json: { data: data }, status: :ok
    rescue => e
      render json: { message: e.message }, status: :not_found
    end
  end

  def new_schema(candidate)
    obj = Struct.new(
      :current_stage_id,
      :workflows,
    ) do
        def workflows=(workflows)
          self[:workflows] = new_workflow(workflows)
        end

        private
        def new_workflow(workflows)
          workflows.map do |workflow|
            {
              id: workflow.stage.id,
              name: workflow.stage.name,
              is_ended: workflow.stage.is_ended,
              is_passed: workflow.passed?,
              is_cancelled: workflow.cancelled?,
              exited_at: workflow.exited_at,
              entered_at: workflow.entered_at,
              order: workflow.stage.order,
              reviewers: new_reviewer(workflow.reviewers)
            }
          end
        end

        def new_reviewer(reviewers)
          reviewers.map do |reviewer|
            {
              id: reviewer.id,
              phase: reviewer.phase,
              feedback: reviewer.feedback,
              decided_at: reviewer.decided_at,
              user_id: reviewer.user_id
            }
          end
        end


    end

    instance = obj.new(
      candidate.last_workflow_stage.stage_id,
      {},
    )

    instance.workflows = candidate.workflows
    instance
  end

end
