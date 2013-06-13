module Lims::WarehouseBuilder
  module Model
    class Sample < Sequel::Model(:historic_samples)
      
      include ResourceTools::Mapping
      include Common

      translate({
        :dna__pre_amplified => :dna_pre_amplified,
        :dna__date_of_sample_extraction => :dna_date_of_sample_extraction,
        :dna__extraction_method => :dna_extraction_method,
        :dna__concentration => :dna_concentration,
        :dna__sample_purified => :dna_sample_purified,
        :dna__concentration_determined_by_which_method => :dna_concentration_determined_by_which_method,
        :rna__pre_amplified => :rna_pre_amplified,
        :rna__date_of_sample_extraction => :rna_date_of_sample_extraction,
        :rna__extraction_method => :rna_extraction_method,
        :rna__concentration => :rna_concentration,
        :rna__sample_purified => :rna_sample_purified,
        :rna__concentration_determined_by_which_method => :rna_concentration_determined_by_which_method,
        :genotyping__country_of_origin => :genotyping_country_of_origin,
        :genotyping__geographical_region => :genotyping_geographical_region,
        :genotyping__ethnicity => :genotyping_ethnicity,
        :cellular_material__lysed => :cellular_material_lysed
      })

    end
  end
end
