class Stage < ApplicationRecord
  belongs_to :parent_id
  belongs_to :post


  def same_post?(stage)
    post_id == stage.post_id
  end
end
