Sequel.migration do
  change do
    alter_table :sample_container_helper do
      add_column :container_model, String
    end
  end
end
