class MigrateTierFromOptionsToLenders < ActiveRecord::Migration[5.0]
  def up
    Lender.all.each do |lender|
      option = lender.options.first
      next unless option
      lender.update_columns tier: option.buydown_tier
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
