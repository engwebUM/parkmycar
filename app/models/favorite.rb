class Favorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :space
  scope :by_last_created, -> { order(created_at: :desc) }
end
