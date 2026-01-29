class Stage < ApplicationRecord
  belongs_to :parent_id
  belongs_to :post


  def same_post?(next_stage)
    post_id == next_stage.post_id
  end
end
