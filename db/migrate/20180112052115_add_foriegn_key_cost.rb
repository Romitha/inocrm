class AddForiegnKeyCost < ActiveRecord::Migration
  def change

    add_foreign_key :mst_spt_product_brand_cost, :mst_currency, name: :fk_mst_spt_product_brand_cost_currency_id, column: :currency_id
  end
end
