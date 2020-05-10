class ServiceArea < ApplicationRecord
  extend Mobility
  translates :name
  translates :description, type: :text

  after_initialize :create_location_if_not_exists

  belongs_to :parent, class_name: "ServiceArea", inverse_of: :service_areas, optional: true
  belongs_to :organization, optional: true
  belongs_to :location, class_name: "Location", inverse_of: :service_areas, foreign_key: :location_id

  has_many :mobility_string_translations, inverse_of: :translatable, class_name: "MobilityStringTranslation", foreign_key: :translatable_id

  has_many :asks, class_name: "Ask", foreign_key: "service_area_id", inverse_of: :service_area
  has_many :offers, class_name: "Offer", foreign_key: "service_area_id", inverse_of: :service_area
  has_many :listings
  has_many :people
  has_many :service_areas, inverse_of: :parent

  validates :name, presence: true

  accepts_nested_attributes_for :location

  TYPES = %w[pod neighborhood region county]

  scope :order_by_translated_name, -> (locale=:en){
    includes(:mobility_string_translations).references(:mobility_string_translations).
    where("mobility_string_translations.locale = ?", locale.to_s).
    where("mobility_string_translations.key = ?", 'name').
    order(MobilityStringTranslation.arel_table["value"].lower.asc)
  }

  scope :as_filter_types, -> { i18n.select :id, :name }

  def full_name
    "#{ parent.name.upcase + ": " if parent}#{name}#{ " (" + service_area_type + ")" if service_area_type}"
  end

  private

  def create_location_if_not_exists
    unless location_id.present?
      location_type = LocationType.where(name: LocationType::SERVICE_AREA_TYPE).first_or_create!
      build_location(location_type: location_type)
    end
  end
end
