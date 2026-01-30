module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end


  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end


  class JsonWebToken
    def initialize(secret)
      @_secret = secret.to_s
    end

    def claim_for(user)
      payload = Struct.new(
        :sub, :exp, :iat, # ....
      ) do
        def expired?
          Time.now >= exp
        end
      end

      JWT.encode(payload.new(
        sub: user.id,
        exp: 10.minutes.from_now.to_i,
        iat: Time.now
      ), @_secret)
    end

    def decode(token)
      raise "JWT token has expired" unless payload.expired?
      JWT.decode(token, @_secret)
    end
  end

  def authenticated?
    resume_session
  end

  def start_new_token_for(user)
    # TODO: ...
    jwt.claim_for(user).to_s
  end

  def require_authentication
    resume_session || raise_request_authentication
  end

  def raise_request_authentication
    render json: { message: "unauthorized" }, status: :unauthorized
  end

  def resume_session
    Current.user ||= perform_authenticate_token
  end


  private
  def jwt
    @instance ||= JsonWebToken.new(
      Rails.application.secrets.secret_key_base
    )
  end

  def resolve_token
    request.headers["Authorization"]&.split&.last.to_s
  end

  def perform_authenticate_token
    token = resolve_token
    begin
      payload = jwt.decode(token)
      Current.user = User.find(payload.sub)
    rescue => e
      nil
    end
  end

end
