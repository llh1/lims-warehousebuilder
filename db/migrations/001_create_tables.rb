require 'lims-warehousebuilder/core_ext'

DNA_RNA_MANUAL_EXTRACTION_ROLES = [
  "eppendorf_tube_dna",
  "eppendorf_tube_dna_to_be_retubed_batched",
  "eppendorf_tube_rna",
  "eppendorf_tube_rna_to_be_retubed_batched",
  "fluidx_tube_dna_to_be_racked",
  "fluidx_tube_rna_to_be_racked",
  "manual_dna_and_rna_byproduct_tube_rnap",
  "manual_dna_and_rna_input_tube_nap",
  "manual_dna_and_rna_input_tube_nap_batched",
  "manual_dna_and_rna_input_tube_rnap_batched",
  "manual_dna_only_input_tube_dnap",
  "manual_dna_only_input_tube_dnap_batched",
  "manual_rna_only_input_tube_rnap",
  "manual_rna_only_input_tube_rnap_batched",
  "manual_spin_column_dna",
  "manual_spin_column_rna",
  "qiacube_dna_and_rna_byproduct_tube_rnap",
  "qiacube_dna_and_rna_input_tube_dnap_batched",
  "qiacube_dna_and_rna_input_tube_dnap_to_be_retubed",
  "qiacube_dna_and_rna_input_tube_nap",
  "qiacube_dna_and_rna_input_tube_nap_batched",
  "qiacube_dna_and_rna_input_tube_nap_to_be_retubed_batched",
  "qiacube_dna_and_rna_input_tube_rnap_batched",
  "qiacube_dna_only_input_tube_dnap",
  "qiacube_dna_only_input_tube_dnap_batched",
  "qiacube_dna_only_input_tube_dnap_to_be_retubed",
  "qiacube_dna_only_input_tube_dnap_to_be_retubed_batched",
  "qiacube_rna_only_input_tube_rnap",
  "qiacube_rna_only_input_tube_rnap_batched",
  "qiacube_rna_only_input_tube_rnap_to_be_retubed",
  "qiacube_rna_only_input_tube_rnap_to_be_retubed_batched",
  "plates_working_dilution_dna",
  "plates_working_dilution_rna",
  "rack_stock_dna",
  "rack_stock_dna_volume_checked",
  "rack_stock_dna_volume_control_added",
  "rack_stock_rna",
  "rack_stock_rna_volume_checked"
].map(&:contract)
# TODO: add cancelled and failed
ORDER_ITEM_STATUS = ["pending", "in_progress", "done", "unused"]

Sequel.migration do
  up do

    # sample_management_activity
    [:current_sample_management_activity, :historic_sample_management_activity].each do |table|
      sequel = "create_table :#{table} do;".tap do |s|
        s << "primary_key :internal_id;"
        s << "String :uuid, :fixed => true, :size => 64;" << "\n"
        DNA_RNA_MANUAL_EXTRACTION_ROLES.each do |role|
          s << "String :#{role}_uuid, :fixed => true, :size => 64;" << "\n"
          ORDER_ITEM_STATUS.each do |status|
            s << "String :#{role}_#{status}_by, :fixed => true, :size => 64;" << "\n"
            s << "DateTime :#{role}_#{status}_at;" << "\n"
          end
        end
        s << "index :uuid;" if table.to_s == "current_sample_management_activity"
        s << "end"
      end
      self.instance_eval(sequel)
    end

    # tubes
    create_table :current_tubes do
      primary_key :internal_id
      String :uuid, :fixed => true, :size => 64
      String :type
      Integer :max_volume
      DateTime :created_at
      DateTime :updated_at
      String :created_by
      String :updated_by
      index :uuid
    end

    create_table :historic_tubes do
      primary_key :internal_id
      String :uuid, :fixed => true, :size => 64
      String :type
      Integer :max_volume
      DateTime :created_at
      DateTime :updated_at
      String :created_by
      String :updated_by
    end

    # tube_racks
    create_table :current_tube_racks do
      primary_key :internal_id
      String :uuid, :fixed => true, :size => 64
      Integer :number_of_rows
      Integer :number_of_columns
      DateTime :created_at
      DateTime :updated_at
      String :created_by
      String :updated_by
      index :uuid
    end

    create_table :historic_tube_racks do
      primary_key :internal_id
      String :uuid, :fixed => true, :size => 64
      Integer :number_of_rows
      Integer :number_of_columns
      DateTime :created_at
      DateTime :updated_at
      String :created_by
      String :updated_by
    end

    # spin columns
    create_table :current_spin_columns do
      primary_key :internal_id
      String :uuid, :fixed => true, :size => 64
      DateTime :created_at
      DateTime :updated_at
      String :created_by
      String :updated_by
      index :uuid
    end

    create_table :historic_spin_columns do
      primary_key :internal_id
      String :uuid, :fixed => true, :size => 64
      DateTime :created_at
      DateTime :updated_at
      String :created_by
      String :updated_by
    end

    # samples
    create_table :current_samples do
      primary_key :internal_id
      String :uuid, :fixed => true, :size => 64
      String :name
      DateTime :created_at
      DateTime :updated_at
      String :created_by
      String :updated_by
      index :uuid
    end

    create_table :historic_samples do
      primary_key :internal_id
      String :uuid, :fixed => true, :size => 64
      String :name
      DateTime :created_at
      DateTime :updated_at
      String :created_by
      String :updated_by
    end

    # orders
    create_table :current_orders do
      primary_key :internal_id
      String :uuid, :fixed => true, :size => 64
      String :pipeline
      String :status
      String :cost_code
      DateTime :created_at
      DateTime :updated_at
      String :created_by
      String :updated_by
      index :uuid
    end

    create_table :historic_orders do
      primary_key :internal_id
      String :uuid, :fixed => true, :size => 64
      String :pipeline
      String :status
      String :cost_code
      DateTime :created_at
      DateTime :updated_at
      String :created_by
      String :updated_by
    end

    # items
    create_table :current_items do
      primary_key :internal_id
      String :uuid, :fixed => true, :size => 64
      String :batch_uuid, :fixed => true, :size => 64
      String :status
      String :role
      DateTime :created_at
      DateTime :updated_at
      String :created_by
      String :updated_by
      index :uuid
    end

    create_table :historic_items do
      primary_key :internal_id
      String :uuid, :fixed => true, :size => 64
      String :batch_uuid, :fixed => true, :size => 64
      String :status
      String :role
      DateTime :created_at
      DateTime :updated_at
      String :created_by
      String :updated_by
    end

    # helper
    create_table :sample_container_helper do
      primary_key :internal_id
      String :sample_uuid, :fixed => true, :size => 64
      String :container_uuid, :fixed => true, :size => 64
      index :container_uuid
    end
 end


  down do
    drop_table :current_sample_management_activity
    drop_table :historic_sample_management_activity
    drop_table :current_tubes
    drop_table :historic_tubes
    drop_table :current_tube_racks
    drop_table :historic_tube_racks
    drop_table :current_spin_columns
    drop_table :historic_spin_columns
    drop_table :current_samples
    drop_table :historic_samples
    drop_table :current_orders
    drop_table :historic_orders
    drop_table :current_items
    drop_table :historic_items
    drop_table :sample_container_helper
  end
end

