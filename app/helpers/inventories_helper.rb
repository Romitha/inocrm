module InventoriesHelper
  def boolean_in_word boolean_value, true_word, false_word
    if boolean_value
      true_word.html_safe
    else
      false_word.html_safe
    end
  end
end


def inventory_search_types( from_where, inventory_product = nil, *args )
  options = args.extract_options!

  if inventory_product.present?
    inventories = inventory_product.inventories{|i| options[:store_id].present? ? (i if options[:store_id].to_i == i.store_id.to_i ) : i }.compact
    available_quantities = inventories.sum{|i| i.available_quantity.to_f }

    if options[:store_id].present?
      stock_quantity = inventory_product.inventories.sum{ |i| i.store_id.to_i == options[:store_id].to_i ? i.stock_quantity.to_f : 0 }
    end
  end

  inventory_product_attr = {
    brand: inventory_product.try(:category1_name),
    product: inventory_product.try(:category2_name),
    category: inventory_product.try(:category3_name),
    serial_code: inventory_product.try(:generated_serial_no),
    item_code: inventory_product.try(:generated_item_code),
    description: inventory_product.try(:description),
    model_no: inventory_product.try(:model_no),
    product_no: inventory_product.try(:product_no),
    part_no: inventory_product.try(:spare_part_no),
    manufacture: inventory_product.try(:manufacture),
    unit: inventory_product.try(:inventory_unit).try(:unit),
  }

  more_info = {
    stock_quantity: stock_quantity
  }

  if block_given?
    yield(more_info)
  else
    case from_where
    when "search_inventory_product"
      inventory_product_attr
    when "inventories"
      inventory_product_attr.merge({
        available_quantity: available_quantities,
        stock_cost: inventory_product.try(:stock_cost),
      })

    when "prn"
      inventory_product_attr.merge({
        available_quantity: available_quantities
      })
    end
  end

end