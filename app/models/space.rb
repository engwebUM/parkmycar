class Space < ActiveRecord::Base
  has_many :reviews, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :attachments, dependent: :destroy
  accepts_nested_attributes_for :attachments
  belongs_to :user
  geocoded_by :address
  after_validation :geocode, if: :address_changed?
end
