Sequel.migration do
  up do
    create_table :current_aliquots do
      primary_key :internal_id
      String :container_uuid, :fixed => true, :size => 64
      String :position
      String :sample_uuid, :fixed => true, :size => 64
      Integer :quantity
      String :type
      Float :concentration
      DateTime :created_at
      DateTime :updated_at
      String :created_by
      String :updated_by
      index [:container_uuid, :position, :sample_uuid], :unique => true
    end

    create_table :historic_aliquots do
      primary_key :internal_id
      String :container_uuid, :fixed => true, :size => 64
      String :position
      String :sample_uuid, :fixed => true, :size => 64
      Integer :quantity
      String :type
      Float :concentration
      DateTime :created_at
      DateTime :updated_at
      String :created_by
      String :updated_by
    end
  end

  down do
    drop_table :current_aliquots
    drop_table :historic_aliquots
  end
end
