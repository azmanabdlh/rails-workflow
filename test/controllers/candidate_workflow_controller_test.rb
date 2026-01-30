require "test_helper"

class CandidateWorkflowControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email: "reviewer@example.com",
      password: "password123"
    )

    @post = Post.create!(title: "Backend Engineer")

    @stage1 = Stage.create!(
      post: @post,
      order: 1,
      name: "Initial Screen",
      is_ended: false
    )

    @stage2 = Stage.create!(
      post: @post,
      order: 2,
      name: "Technical Interview",
      is_ended: false
    )

    @stage3 = Stage.create!(
      post: @post,
      order: 3,
      name: "Final Round",
      is_ended: false
    )

    @candidate = Candidate.create!(
      email: "candidate@example.com",
      name: "John Doe",
      current_stage_id: @stage1.id
    )

    @candidate_stage = CandidateStage.create!(
      candidate: @candidate,
      stage: @stage1,
      entered_at: Time.current
    )

    @reviewer = Reviewer.create!(
      candidate_stage: @candidate_stage,
      user: @user,
      phase: "pending"
    )
  end

  def get_fresh_token
    post "/api/login", params: {
      email: "reviewer@example.com",
      password: "password123"
    }
    JSON.parse(response.body)["token"]
  end

  def auth_headers(token = nil)
    token ||= get_fresh_token
    { "Authorization" => "Bearer #{token}" }
  end

  test "should transition candidate with valid stage" do
    post "/api/candidate/workflow", params: {
      phase: "passed",
      candidate_id: @candidate.id,
      stage_id: @stage2.id,
      feedback: "Great technical knowledge"
    }, headers: auth_headers

    assert_response :ok
    response_body = JSON.parse(response.body)
    assert_equal "success", response_body["message"]
  end

  test "should return bad_request for invalid stage transition order" do
    # Try to skip a stage (go from stage 1 to stage 3)
    post "/api/candidate/workflow", params: {
      phase: "passed",
      candidate_id: @candidate.id,
      stage_id: @stage3.id,
      feedback: "Great performance"
    }, headers: auth_headers

    assert_response :bad_request
    response_body = JSON.parse(response.body)
    assert_equal "invalid stage transition", response_body["message"]
  end

  test "should return error when candidate not found" do
    post "/api/candidate/workflow", params: {
      phase: "passed",
      candidate_id: 99999,
      stage_id: @stage2.id,
      feedback: "Test feedback"
    }, headers: auth_headers

    assert_response :not_found
  end

  test "should return error when stage not found" do
    post "/api/candidate/workflow", params: {
      phase: "passed",
      candidate_id: @candidate.id,
      stage_id: 99999,
      feedback: "Test feedback"
    }, headers: auth_headers

    assert_response :not_found
  end

  test "should handle invalid phase" do
    post "/api/candidate/workflow", params: {
      phase: "invalid_phase",
      candidate_id: @candidate.id,
      stage_id: @stage2.id,
      feedback: "Test feedback"
    }, headers: auth_headers

    assert_response :bad_request
  end

  test "should reject transition from ended stage" do
    @stage1.update!(is_ended: true)

    post "/api/candidate/workflow", params: {
      phase: "passed",
      candidate_id: @candidate.id,
      stage_id: @stage2.id,
      feedback: "Test feedback"
    }, headers: auth_headers

    assert_response :bad_request
    response_body = JSON.parse(response.body)
    assert_equal "invalid stage transition", response_body["message"]
  end

  test "should permit required parameters" do
    assert_nothing_raised do
      post "/api/candidate/workflow", params: {
        phase: "passed",
        candidate_id: @candidate.id,
        stage_id: @stage2.id,
        feedback: "Complete feedback"
      }, headers: auth_headers
    end
  end

  test "should handle transition with nil feedback" do
    post "/api/candidate/workflow", params: {
      phase: "passed",
      candidate_id: @candidate.id,
      stage_id: @stage2.id,
      feedback: nil
    }, headers: auth_headers

    # Should either succeed or fail gracefully
    assert [200, 400].include?(response.status)
  end

  test "should return json response format" do
    post "/api/candidate/workflow", params: {
      phase: "passed",
      candidate_id: @candidate.id,
      stage_id: @stage2.id,
      feedback: "Test"
    }, headers: auth_headers

    assert_match "application/json", response.content_type
    assert_nothing_raised { JSON.parse(response.body) }
  end

  test "should update candidate stage after successful transition" do
    post "/api/candidate/workflow", params: {
      phase: "passed",
      candidate_id: @candidate.id,
      stage_id: @stage2.id,
      feedback: "Good performance"
    }, headers: auth_headers

    @candidate.reload
    assert_equal @stage2.id, @candidate.current_stage_id
  end

  test "should create new candidate stage for next stage" do
    post "/api/candidate/workflow", params: {
      phase: "passed",
      candidate_id: @candidate.id,
      stage_id: @stage2.id,
      feedback: "Passed first stage"
    }, headers: auth_headers

    new_stage = @candidate.candidate_stages.find_by(stage_id: @stage2.id)
    assert_not_nil new_stage
    assert_not_nil new_stage.entered_at
  end

  test "should mark previous stage as exited after transition" do
    post "/api/candidate/workflow", params: {
      phase: "passed",
      candidate_id: @candidate.id,
      stage_id: @stage2.id,
      feedback: "Passed stage 1"
    }, headers: auth_headers

    @candidate_stage.reload
    assert_not_nil @candidate_stage.exited_at
  end

  test "should include feedback in reviewer mark" do
    feedback_text = "Excellent problem solving skills"

    post "/api/candidate/workflow", params: {
      phase: "passed",
      candidate_id: @candidate.id,
      stage_id: @stage2.id,
      feedback: feedback_text
    }, headers: auth_headers

    assert_response :ok
    # Feedback should be stored in reviewer
    @reviewer.reload
    assert_equal feedback_text, @reviewer.feedback
  end

  test "should handle transition with different phase types" do
    phases = ["passed", "cancelled"]

    phases.each do |phase|
      candidate = Candidate.create!(
        email: "candidate_#{phase}@example.com",
        name: "Test Candidate #{phase}",
        current_stage_id: @stage1.id
      )

      candidate_stage = CandidateStage.create!(
        candidate: candidate,
        stage: @stage1,
        entered_at: Time.current
      )

      Reviewer.create!(
        candidate_stage: candidate_stage,
        user: @user,
        phase: "pending"
      )

      post "/api/candidate/workflow", params: {
        phase: phase,
        candidate_id: candidate.id,
        stage_id: @stage2.id,
        feedback: "Test #{phase}"
      }, headers: auth_headers

      assert_response :ok, "Failed for phase: #{phase}"
    end
  end
end
