class Deal < ActiveRecord::Base
  include AASM
  include Province
  include Taxable

  COMPOUNDING_FREQUENCIES = [:biweekly, :monthly, :semimonthly, :weekly]

  enum min_frequency: COMPOUNDING_FREQUENCIES, _prefix: :min
  enum max_frequency: COMPOUNDING_FREQUENCIES, _prefix: :max

  enum state: [:product_list, :worksheet, :active]
  enum tax: [:no, :one, :two]

  belongs_to :user
  has_one :client, as: :contactable, class_name: 'Contact', dependent: :destroy
  has_one :product_list, as: :listable, dependent: :destroy
  has_many :lenders, dependent: :destroy, inverse_of: :deal

  accepts_nested_attributes_for :client
  accepts_nested_attributes_for :lenders

  validates :province_id, presence: true, on: :update

  validates_associated :client
  validates_associated :lenders

  before_create :set_province, :set_tax, :set_product_list, :set_lenders

  monetize :min_payment_cents, :max_payment_cents, numericality: { greater_than_or_equal_to: 0 }

  aasm column: :state, skip_validation_on_save: true do
    state :product_list, initial: true
    state :worksheet
    state :active

    event :product_list_done do
      transitions to: :worksheet
    end

    event :worksheet_done do
      transitions to: :active
    end
  end

  def tax_type
    tax
  end

  def pst_rate
    province.pst
  end

  def gst_rate
    province.gst
  end

  def tax_trade_in_not_allowed?(type)
    !send(:"#{type}_trade_in_allowance?")
  end

  private

  def set_province
    self.province_id = user.dealership.province_id
  end

  def set_tax
    tax = 'no'
    tax = 'one' unless province.gst.zero?
    tax = 'two' unless province.pst.zero?
    self.tax = tax
  end

  def set_product_list
    self.product_list = user.product_list.deep_clone(include: [:products, insurance_policies: [:insurance_rates]])
  end

  def set_lenders
    lenders.build position: 'left'
    lenders.build position: 'right'
  end
end
