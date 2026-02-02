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
      @secret = secret.to_s
      @schema = Struct.new(
        :sub, :exp, :iat, # ....
      ) do
        def expired?
          Time.now >= Time.at(exp)
        end
      end

    end

    def claim_for(user)
      payload = @schema.new(
        sub: user.id,
        exp: 15.minutes.from_now.to_i,
        iat: Time.now
      )
      JWT.encode(payload.to_json, @secret)
    end

    def resolve(payload)
      @schema.new(
        sub: payload["sub"],
        exp: payload["exp"],
        iat: payload["iat"]
      )
    end

    def decode!(token)
      raw = JWT.decode(token, @secret)
      raise "invalid token" if raw.empty? || raw[0].blank?

      payload = JSON.parse(raw[0])

      resolve(payload)
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
    @_jwt ||= JsonWebToken.new(
      Rails.application.credentials.secret_key_base
    )
  end

  def resolve_token
    request.headers["Authorization"]&.split&.last.to_s
  end

  def perform_authenticate_token
    token = resolve_token
    return nil if token.empty?

    payload = jwt.decode!(token)

    Current.user = User.find(payload.sub) unless payload.expired?
  end

end
