module Lims::WarehouseBuilder
  module Contractions
    CONTRACTIONS = {
      "dna_only"            => "dna",
      "rna_only"            => "rna",
      "dna_and_rna"         => "dnr",
      "qiacube"             => "q3",
      "batched"             => "b",
      "samples_"            => "",
      "samples_extraction_" => ""
    }
    CONTRACTION_REGEX = Regexp.new(CONTRACTIONS.keys.join('|'))

    def contract
      gsub(CONTRACTION_REGEX) { |m| Contractions::CONTRACTIONS[m] || m }
    end
  end
end

class String
  include ::Lims::WarehouseBuilder::Contractions
end
