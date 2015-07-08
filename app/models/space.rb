class Space < ActiveRecord::Base
  require 'action_view'
  include ActionView::Helpers::NumberHelper
  belongs_to :user
  has_many :reviews, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :attachments, dependent: :destroy
  scope :by_last_created, -> { order(created_at: :desc) }

  geocoded_by :full_street_address
  after_validation :geocode, if: :full_street_address_changed?

  NUMBER_REGEX = /\A\d+(?:\.\d{0,2})?\z/

  validates :title, presence: true
  validates :available_spaces, presence: true, numericality: { greater_than: 0 }
  validates :description, presence: true
  validates :country, presence: true
  validates :city, presence: true
  validates :address, presence: true
  validates :post_code, presence: true
  validates :price_hour, presence: true, format: NUMBER_REGEX, numericality: { greater_than: 0 }
  validates :price_week, format: NUMBER_REGEX, allow_blank: true, numericality: { greater_than: 0 }
  validates :price_month, format: NUMBER_REGEX, allow_blank: true, numericality: { greater_than: 0 }
  validates :date_from, presence: true
  validates :date_until, presence: true
  validate :valid_dates_interval

  def self.filter_by(date_from, date_until, available_weekend)
    filtered = Space.where(nil)
    filtered = filtered.where('date_from <= ?', date_from.to_datetime) if valid_date?(date_from)
    filtered = filtered.where('date_until >= ?', date_until.to_datetime) if valid_date?(date_until)
    filtered = filtered.where(available_weekend: true) if available_weekend == 'true'
    filtered
  end

  def full_street_address
    "#{address}, #{city}, #{country}"
  end

  def full_street_address_changed?
    address_changed? || city_changed? || country_changed?
  end

  def self.sort_by(sort_param)
    sorted = Space.where(nil)
    if sort_param == 'pri'
      sorted = sorted.reorder(:price_hour)
    elsif sort_param == 'rev'
      sorted = sorted.reorder(reviews_count: :desc)
    end
    sorted
  end

  def self.valid_date?(date)
    date.to_datetime
    rescue ArgumentError, NoMethodError
      false
  end

  def owner_avatar
    user.photo
  end

  def owner_rating
    number_with_precision(user.spaces.joins(:reviews).average(:evaluation), precision: 2).to_f
  end

  def first_image
    if attachments.empty?
      'no_image.png'
    else
      attachments.first.file_name.url(:thumb)
    end
  end

  def valid_dates_interval
    errors.add(:date_from, 'cannot be higher than date until') unless date_from.to_datetime < date_until.to_datetime
  end

  def weekend
    if available_weekend
      'including weekends'
    else
      'excluding weekends'
    end
  end
end
