class Post < ApplicationRecord

  def expired?
    now = Time.now
    ended_at.presence and  now > ended_at
  end

end
