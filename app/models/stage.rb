class Stage < ApplicationRecord
  belongs_to :parent, class_name: "Stage", optional: true
  belongs_to :post

  has_one :workflow

  def same_post?(stage)
    post_id == stage.post_id
  end
end
