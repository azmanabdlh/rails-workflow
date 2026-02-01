class Stage < ApplicationRecord
  belongs_to :parent, class_name: "Stage", optional: true
  belongs_to :post

  has_one :workflow
  has_many :children, class_name: "Stage", foreign_key: "parent_id"

  def same_post?(to)
    post_id == to.post_id
  end

  def has_children?
    children.size > 0
  end

  def child?
    parent_id != nil
  end

  def sibling?(to)
    parent_id == to.parent_id && direct_to?(to)
  end

  def direct_to?(to)
    (order + 1) == to.order
  end

  def leave_sub?(to)
    child? && (parent.order + 1) == to.order
  end

  def enter_sub?(to)
    to.child? && (order + 1) == to.parent.order
  end

end
