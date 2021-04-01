require 'rails_helper'

RSpec.describe Calculator::Lease, type: :calculation do
  subject { described_class.new attributes }

  let(:attributes) { attributes_for :lease, amount: amount, frequency: frequency, rate: rate, residual: residual, rebate: rebate, tax: tax, term: term, lien: lien }

  LeaseScenario = Struct.new :amount, :frequency, :rate, :residual, :rebate, :tax, :term, :lien, :cost_of_borrowing, :payment

  [
    LeaseScenario.new(50_000_00, :monthly,  0.000,         0,     0,    0, 60,        0,         0,  833_33),
    LeaseScenario.new(50_000_00, :monthly,  0.025,         0,     0,    0, 60,        0,  3_131_20,  885_52),
    LeaseScenario.new(50_000_00, :monthly,  0.050,         0,     0,    0, 60,        0,  6_379_00,  939_65),
    LeaseScenario.new(50_000_00, :monthly,  0.075,         0,     0,    0, 60,        0,  9_740_20,  995_67),

    LeaseScenario.new(50_000_00, :monthly,  0.000, 25_000_00,     0,    0, 60,        0,         0,  416_67),
    LeaseScenario.new(50_000_00, :monthly,  0.025, 25_000_00,     0,    0, 60,        0,  4_684_40,  494_74),
    LeaseScenario.new(50_000_00, :monthly,  0.050, 25_000_00,     0,    0, 60,        0,  9_413_60,  573_56),
    LeaseScenario.new(50_000_00, :monthly,  0.075, 25_000_00,     0,    0, 60,        0, 14_187_20,  653_12),

    LeaseScenario.new(50_000_00, :monthly,  0.000, 25_000_00,     0, 0.12, 60,         0,         0,  466_67),
    LeaseScenario.new(50_000_00, :monthly,  0.025, 25_000_00,     0, 0.12, 60,         0,  5_246_53,  554_11),
    LeaseScenario.new(50_000_00, :monthly,  0.050, 25_000_00,     0, 0.12, 60,         0, 10_543_23,  642_39),
    LeaseScenario.new(50_000_00, :monthly,  0.075, 25_000_00,     0, 0.12, 60,         0, 15_889_66,  731_49),

    LeaseScenario.new(50_000_00, :monthly,  0.000, 50_000_00,     0,    0, 60,         0,         0,       0),
    LeaseScenario.new(50_000_00, :monthly,  0.025, 50_000_00,     0,    0, 60,         0,  6_237_00,  103_95),
    LeaseScenario.new(50_000_00, :monthly,  0.050, 50_000_00,     0,    0, 60,         0, 12_448_20,  207_47),
    LeaseScenario.new(50_000_00, :monthly,  0.075, 50_000_00,     0,    0, 60,         0, 18_633_60,  310_56),

    LeaseScenario.new(50_000_00, :monthly,  0.000, 18_500_00,     0,    0, 60,         0,         0,  525_00),
    LeaseScenario.new(50_000_00, :monthly,  0.025, 18_500_00,     0,    0, 60,         0,  4_280_40,  596_34),
    LeaseScenario.new(50_000_00, :monthly,  0.050, 18_500_00,     0,    0, 60,         0,  8_624_40,  668_74),
    LeaseScenario.new(50_000_00, :monthly,  0.075, 18_500_00,     0,    0, 60,         0, 13_030_80,  742_18),

    LeaseScenario.new(30_000_00, :monthly,  0.000, 12_900_00,     0, 0.12, 60, 10_000_00,         0,  485_87),
    LeaseScenario.new(30_000_00, :monthly,  0.025, 12_900_00,     0, 0.12, 60, 10_000_00,  3_650_02,  546_70),
    LeaseScenario.new(30_000_00, :monthly,  0.050, 12_900_00,     0, 0.12, 60, 10_000_00,  7_363_21,  608_59),
    LeaseScenario.new(30_000_00, :monthly,  0.075, 12_900_00,     0, 0.12, 60, 10_000_00, 11_137_81,  671_50),

    LeaseScenario.new(30_000_00, :monthly,  0.000, 12_900_00, 1_000, 0.12, 60, 10_000_00,         0,  485_87),
    LeaseScenario.new(30_000_00, :monthly,  0.025, 12_900_00, 1_000, 0.12, 60, 10_000_00,  3_648_82,  546_70),
    LeaseScenario.new(30_000_00, :monthly,  0.050, 12_900_00, 1_000, 0.12, 60, 10_000_00,  7_362_01,  608_59),
    LeaseScenario.new(30_000_00, :monthly,  0.075, 12_900_00, 1_000, 0.12, 60, 10_000_00, 11_136_61,  671_50),
  ].each do |s|
    context s.to_s do
      let(:amount)    { Money.new s.amount }
      let(:frequency) { s.frequency }
      let(:rate)      { s.rate }
      let(:residual)  { Money.new s.residual }
      let(:rebate)    { Money.new s.rebate }
      let(:tax)       { s.tax }
      let(:term)      { s.term }
      let(:lien)      { Money.new s.lien }

      let(:actual_payment)   { subject.payment }
      let(:expected_payment) { Money.new s.payment }

      let(:actual_cost_of_borrowing)   { subject.cost_of_borrowing }
      let(:expected_cost_of_borrowing) { Money.new s.cost_of_borrowing }

      before do
        subject.calculate!
      end

      it { expect(actual_payment).to eq expected_payment }
      it { expect(actual_cost_of_borrowing).to eq expected_cost_of_borrowing }
    end
  end
end
