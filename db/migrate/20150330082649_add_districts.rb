class AddDistricts < ActiveRecord::Migration
  def change
    create_table :mst_district, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name
      t.timestamps
    end

    add_column :spt_customer, :district_id, "INT UNSIGNED"

    [
      {constraint_name: "fk_spt_customer_mst_district1", foreign_key: "district_id", reference_table: "mst_district"}
    ].each do |attr|
      execute "ALTER TABLE `spt_customer` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    ["Ampara","Anuradhapura", "Badulla", "Batticaloa", "Colombo", "Galle", "Gampaha", "Hambantota", "Jaffna", "Kalutara", "Kandy", "Kegalle", "Kilinochchi", "Kurunegala", "Mannar", "Matale", "Matara", "Moneragala", "Mullaitivu", "Nuwara Eliya", "Polonnaruwa", "Puttalam", "Ratnapura", "Trincomalee", "Vavuniya"
      ].each do |value|
        execute("insert into mst_district (name) values ('#{value}')")
    end

  end
end
