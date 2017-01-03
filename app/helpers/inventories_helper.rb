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
    inventories = inventory_product.inventories.to_a{|i| options[:store_id].present? ? (i if options[:store_id].to_i == i.store_id.to_i ) : i }.compact
    available_quantities = inventories.sum{|i| i.available_quantity.to_f }

    if options[:store_id].present?
      # store = inventory_product.inventories.find_by_store_id(options[:store_id])

      stock_quantity = inventory_product.inventories.sum{ |i| i.store_id.to_i == options[:store_id].to_i ? i.stock_quantity.to_f : 0 }

      store_info = {
        store: inventory_product.stores.select{|s| s.name if s.id.to_f == options[:store_id].to_f }.join(", ")
      }

    end


    more_info = {
      stock_quantity: stock_quantity
    }

    tooltip = {
      brand: inventory_product.category1_name,
      product: inventory_product.category2_name,
      category: inventory_product.category3_name,
      serial_code: inventory_product.generated_serial_no,
      model_no: inventory_product.model_no,
      product_no: inventory_product.product_no,
      part_no: inventory_product.spare_part_no,
      manufacture: inventory_product.manufacture,

    }

  end

  inventory_product_attr = {
    item_code: inventory_product.try(:generated_item_code),
    description: inventory_product.try(:description),
    type: inventory_product.try(:product_type),
    unit: inventory_product.try(:inventory_unit).try(:unit),
    tooltip: tooltip
  }

  if block_given?
    if options[:tooltip].present?
      yield(tooltip)
    else
      yield(more_info)
    end
  else
    case from_where
    when "search_inventory_product"
      inventory_product_attr
    when "inventories"
      inventory_product_attr.merge({
        available_quantity: available_quantities,
        stock_cost: inventory_product.try(:stock_cost)
      })

    when "prn"
      inventory_product_attr.merge({
        available_quantity: available_quantities
      })
    end
  end

end