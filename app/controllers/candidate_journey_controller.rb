class CandidateJourneyController < ApplicationController

  def show
    begin
      data = new_schema(
        Candidate.find(
          params[:candidate_id]
        )
      )
      render json: { data: data || {} }, status: :ok
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
          self[:workflows] = workflows.map do |workflow|
            new_workflow(workflow, workflow.stage)
          end

        end

        private
        def new_workflow(workflow, stage)
           {
              id: stage.id,
              name: stage.name,
              is_ended: stage.is_ended,
              is_passed: workflow.passed?,
              is_cancelled: workflow.cancelled?,
              has_children: stage.has_children?,
              exited_at: workflow.exited_at,
              entered_at: workflow.entered_at,
              order: workflow.stage.order,
              reviewers: workflow.reviewers.map { |r| new_reviewer(r) },
              sub_workflows: stage.children.map { |s| new_workflow(workflow, s) }
            }
        end

        def new_reviewer(reviewer)
          {
            id: reviewer.id,
            phase: reviewer.phase,
            feedback: reviewer.feedback,
            decided_at: reviewer.decided_at,
            user_id: reviewer.user_id
          }
        end


    end


    last_workflow = candidate.last_workflow_stage
    return nil if last_workflow.nil?

    instance = obj.new
    instance.current_stage_id = last_workflow.stage_id
    instance.workflows = candidate.workflows

    instance
  end

end
