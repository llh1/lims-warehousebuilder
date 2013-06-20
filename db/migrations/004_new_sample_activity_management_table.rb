Sequel.migration do
  change do
    drop_table :current_sample_management_activity
    drop_table :historic_sample_management_activity

    create_table :sample_management_activity do
      primary_key :internal_id
      foreign_key :sample_id, :current_samples, :key => :internal_id 
      foreign_key :order_id, :current_orders, :key => :internal_id 
      String :uuid, :fixed => true, :size => 64
      String :process
      String :step
      foreign_key :tube_id, :current_tubes, :key => :internal_id
      foreign_key :spin_column_id, :current_spin_columns, :key => :internal_id
      String :user
      String :status
      DateTime :date
      TrueClass :is_current
      String :hashed_index

      index :hashed_index
      index [:sample_id, :order_id]
    end
  end
end
