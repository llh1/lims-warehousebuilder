require 'lims-warehousebuilder/decoders/spec_helper'
require 'lims-warehousebuilder/builder'
require 'lims-warehousebuilder/json_decoder'
require 'lims-warehousebuilder/model'

module Lims::WarehouseBuilder
  describe Decoder::SampleDecoder do
    include_context "use database"
    include_context "timecop"

    context "Sample payload from lims-management-app" do
      let(:builder) { Builder.new({}) }
      let(:result) { builder.send(:decode_payload, payload, :action => action) }

      context "decode bulk create sample message" do
        let(:action) { "create" }
        let(:payload) {
         JSON.parse <<-EOD
        {"bulk_create_sample":{"actions":{},"user":"user","application":"application","result":{"samples":[{"actions":{"read":"http://localhost:9292/e5eedb40-af42-0130-51be-282066132de2","create":"http://localhost:9292/e5eedb40-af42-0130-51be-282066132de2","update":"http://localhost:9292/e5eedb40-af42-0130-51be-282066132de2","delete":"http://localhost:9292/e5eedb40-af42-0130-51be-282066132de2"},"uuid":"e5eedb40-af42-0130-51be-282066132de2","state":"draft","supplier_sample_name":"supplier sample name","gender":"Male","sanger_sample_id":"S2-267bf57412064031af1e36acc73ab92b","sample_type":"RNA","scientific_name":"homo sapiens","common_name":"man","hmdmc_number":"123456","ebi_accession_number":"accession number","sample_source":"sample source","mother":"mother","father":"father","sibling":"sibling","gc_content":"gc content","public_name":"public name","cohort":"cohort","storage_conditions":"storage conditions","taxon_id":9606,"volume":100,"date_of_sample_collection":"2013-06-24T00:00:00+01:00","is_sample_a_control":true,"is_re_submitted_sample":false,"dna":{"pre_amplified":false,"date_of_sample_extraction":"2013-06-02T00:00:00+00:00","extraction_method":"extraction method","concentration":120,"sample_purified":false,"concentration_determined_by_which_method":"method"},"cellular_material":{"lysed":false},"genotyping":{"country_of_origin":"england","geographical_region":"europe","ethnicity":"english"}},{"actions":{"read":"http://localhost:9292/e5ef1d30-af42-0130-51be-282066132de2","create":"http://localhost:9292/e5ef1d30-af42-0130-51be-282066132de2","update":"http://localhost:9292/e5ef1d30-af42-0130-51be-282066132de2","delete":"http://localhost:9292/e5ef1d30-af42-0130-51be-282066132de2"},"uuid":"e5ef1d30-af42-0130-51be-282066132de2","state":"draft","supplier_sample_name":"supplier sample name","gender":"Male","sanger_sample_id":"S2-87aba12f331e44c7b27c620e5316bb8a","sample_type":"RNA","scientific_name":"homo sapiens","common_name":"man","hmdmc_number":"123456","ebi_accession_number":"accession number","sample_source":"sample source","mother":"mother","father":"father","sibling":"sibling","gc_content":"gc content","public_name":"public name","cohort":"cohort","storage_conditions":"storage conditions","taxon_id":9606,"volume":100,"date_of_sample_collection":"2013-06-24T00:00:00+01:00","is_sample_a_control":true,"is_re_submitted_sample":false,"dna":{"pre_amplified":false,"date_of_sample_extraction":"2013-06-02T00:00:00+00:00","extraction_method":"extraction method","concentration":120,"sample_purified":false,"concentration_determined_by_which_method":"method"},"cellular_material":{"lysed":false},"genotyping":{"country_of_origin":"england","geographical_region":"europe","ethnicity":"english"}},{"actions":{"read":"http://localhost:9292/e5ef5fb0-af42-0130-51be-282066132de2","create":"http://localhost:9292/e5ef5fb0-af42-0130-51be-282066132de2","update":"http://localhost:9292/e5ef5fb0-af42-0130-51be-282066132de2","delete":"http://localhost:9292/e5ef5fb0-af42-0130-51be-282066132de2"},"uuid":"e5ef5fb0-af42-0130-51be-282066132de2","state":"draft","supplier_sample_name":"supplier sample name","gender":"Male","sanger_sample_id":"S2-65a19405eea14b50af6e9c1f81f29278","sample_type":"RNA","scientific_name":"homo sapiens","common_name":"man","hmdmc_number":"123456","ebi_accession_number":"accession number","sample_source":"sample source","mother":"mother","father":"father","sibling":"sibling","gc_content":"gc content","public_name":"public name","cohort":"cohort","storage_conditions":"storage conditions","taxon_id":9606,"volume":100,"date_of_sample_collection":"2013-06-24T00:00:00+01:00","is_sample_a_control":true,"is_re_submitted_sample":false,"dna":{"pre_amplified":false,"date_of_sample_extraction":"2013-06-02T00:00:00+00:00","extraction_method":"extraction method","concentration":120,"sample_purified":false,"concentration_determined_by_which_method":"method"},"cellular_material":{"lysed":false},"genotyping":{"country_of_origin":"england","geographical_region":"europe","ethnicity":"english"}}]},"volume":100,"date_of_sample_collection":"2013-06-24","is_sample_a_control":true,"is_re_submitted_sample":false,"hmdmc_number":"123456","ebi_accession_number":"accession number","sample_source":"sample source","mother":"mother","father":"father","sibling":"sibling","gc_content":"gc content","public_name":"public name","cohort":"cohort","storage_conditions":"storage conditions","dna":{"pre_amplified":false,"date_of_sample_extraction":"2013-06-02","extraction_method":"extraction method","concentration":120,"sample_purified":false,"concentration_determined_by_which_method":"method"},"rna":null,"cellular_material":{"lysed":false},"genotyping":{"country_of_origin":"england","geographical_region":"europe","ethnicity":"english"},"common_name":"man","gender":"Male","sample_type":"RNA","taxon_id":9606,"supplier_sample_name":"supplier sample name","scientific_name":"homo sapiens","quantity":3,"state":"draft"},"action":"bulk_create_sample","date":"2013-06-04 12:47:54 UTC","user":"user"}
        EOD
      }

        it "finds the right number of resources" do
          result.size.should == 3
        end

        it "finds the right resource models" do
          result.each do |resource|
            resource.should be_a(Model::Sample)
          end
        end
      end

      context "decode bulk update sample message" do
        let(:action) { "updatesample" }
        let(:payload) {
          JSON.parse <<-EOD
        {"bulk_update_sample":{"actions":{},"user":"user","application":"application","result":{"samples":[{"actions":{"read":"http://localhost:9292/a0d1f780-af5a-0130-51e4-282066132de2","create":"http://localhost:9292/a0d1f780-af5a-0130-51e4-282066132de2","update":"http://localhost:9292/a0d1f780-af5a-0130-51e4-282066132de2","delete":"http://localhost:9292/a0d1f780-af5a-0130-51e4-282066132de2"},"uuid":"a0d1f780-af5a-0130-51e4-282066132de2","state":"draft","supplier_sample_name":"new supplier sample name","gender":"Hermaphrodite","sanger_sample_id":"S2-bf54c86eb4a943e6b8967beebd750b70","sample_type":"Blood","scientific_name":"Hominidae","common_name":"great apes","hmdmc_number":"new 123456","ebi_accession_number":"new accession number","sample_source":"new sample source","mother":"new mother","father":"new father","sibling":"new sibling","gc_content":"new gc content","public_name":"new public name","cohort":"new cohort","storage_conditions":"new storage conditions","taxon_id":9604,"volume":101,"date_of_sample_collection":"2013-06-24T00:00:00+01:00","is_sample_a_control":false,"is_re_submitted_sample":true,"dna":{"pre_amplified":true,"date_of_sample_extraction":"2013-06-02T00:00:00+00:00","extraction_method":"new extraction method","concentration":121,"sample_purified":true,"concentration_determined_by_which_method":"new method"},"cellular_material":{"lysed":true},"genotyping":{"country_of_origin":"new england","geographical_region":"new europe","ethnicity":"new english"}},{"actions":{"read":"http://localhost:9292/a0d251a0-af5a-0130-51e4-282066132de2","create":"http://localhost:9292/a0d251a0-af5a-0130-51e4-282066132de2","update":"http://localhost:9292/a0d251a0-af5a-0130-51e4-282066132de2","delete":"http://localhost:9292/a0d251a0-af5a-0130-51e4-282066132de2"},"uuid":"a0d251a0-af5a-0130-51e4-282066132de2","state":"draft","supplier_sample_name":"new supplier sample name","gender":"Hermaphrodite","sanger_sample_id":"S2-85f5fbe5a99a4429a9ffdc97bf22593e","sample_type":"Blood","scientific_name":"Hominidae","common_name":"great apes","hmdmc_number":"new 123456","ebi_accession_number":"new accession number","sample_source":"new sample source","mother":"new mother","father":"new father","sibling":"new sibling","gc_content":"new gc content","public_name":"new public name","cohort":"new cohort","storage_conditions":"new storage conditions","taxon_id":9604,"volume":101,"date_of_sample_collection":"2013-06-24T00:00:00+01:00","is_sample_a_control":false,"is_re_submitted_sample":true,"dna":{"pre_amplified":true,"date_of_sample_extraction":"2013-06-02T00:00:00+00:00","extraction_method":"new extraction method","concentration":121,"sample_purified":true,"concentration_determined_by_which_method":"new method"},"cellular_material":{"lysed":true},"genotyping":{"country_of_origin":"new england","geographical_region":"new europe","ethnicity":"new english"}},{"actions":{"read":"http://localhost:9292/a0d29e20-af5a-0130-51e4-282066132de2","create":"http://localhost:9292/a0d29e20-af5a-0130-51e4-282066132de2","update":"http://localhost:9292/a0d29e20-af5a-0130-51e4-282066132de2","delete":"http://localhost:9292/a0d29e20-af5a-0130-51e4-282066132de2"},"uuid":"a0d29e20-af5a-0130-51e4-282066132de2","state":"draft","supplier_sample_name":"new supplier sample name","gender":"Hermaphrodite","sanger_sample_id":"S2-7e7f7fa17d704c0aa3b43d3f69b0e4b2","sample_type":"Blood","scientific_name":"Hominidae","common_name":"great apes","hmdmc_number":"new 123456","ebi_accession_number":"new accession number","sample_source":"new sample source","mother":"new mother","father":"new father","sibling":"new sibling","gc_content":"new gc content","public_name":"new public name","cohort":"new cohort","storage_conditions":"new storage conditions","taxon_id":9604,"volume":101,"date_of_sample_collection":"2013-06-24T00:00:00+01:00","is_sample_a_control":false,"is_re_submitted_sample":true,"dna":{"pre_amplified":true,"date_of_sample_extraction":"2013-06-02T00:00:00+00:00","extraction_method":"new extraction method","concentration":121,"sample_purified":true,"concentration_determined_by_which_method":"new method"},"cellular_material":{"lysed":true},"genotyping":{"country_of_origin":"new england","geographical_region":"new europe","ethnicity":"new english"}}]},"by":null,"updates":{"a0d1f780-af5a-0130-51e4-282066132de2":{"gender":"Hermaphrodite","sample_type":"Blood","taxon_id":9604,"volume":101,"supplier_sample_name":"new supplier sample name","common_name":"great apes","scientific_name":"Hominidae","hmdmc_number":"new 123456","ebi_accession_number":"new accession number","sample_source":"new sample source","mother":"new mother","father":"new father","sibling":"new sibling","gc_content":"new gc content","public_name":"new public name","cohort":"new cohort","storage_conditions":"new storage conditions","date_of_sample_collection":"new 2013-06-24","is_sample_a_control":false,"is_re_submitted_sample":true,"dna":{"pre_amplified":true,"date_of_sample_extraction":"new 2013-06-02","extraction_method":"new extraction method","concentration":121,"sample_purified":true,"concentration_determined_by_which_method":"new method"},"cellular_material":{"lysed":true},"genotyping":{"country_of_origin":"new england","geographical_region":"new europe","ethnicity":"new english"}},"a0d251a0-af5a-0130-51e4-282066132de2":{"gender":"Hermaphrodite","sample_type":"Blood","taxon_id":9604,"volume":101,"supplier_sample_name":"new supplier sample name","common_name":"great apes","scientific_name":"Hominidae","hmdmc_number":"new 123456","ebi_accession_number":"new accession number","sample_source":"new sample source","mother":"new mother","father":"new father","sibling":"new sibling","gc_content":"new gc content","public_name":"new public name","cohort":"new cohort","storage_conditions":"new storage conditions","date_of_sample_collection":"new 2013-06-24","is_sample_a_control":false,"is_re_submitted_sample":true,"dna":{"pre_amplified":true,"date_of_sample_extraction":"new 2013-06-02","extraction_method":"new extraction method","concentration":121,"sample_purified":true,"concentration_determined_by_which_method":"new method"},"cellular_material":{"lysed":true},"genotyping":{"country_of_origin":"new england","geographical_region":"new europe","ethnicity":"new english"}},"a0d29e20-af5a-0130-51e4-282066132de2":{"gender":"Hermaphrodite","sample_type":"Blood","taxon_id":9604,"volume":101,"supplier_sample_name":"new supplier sample name","common_name":"great apes","scientific_name":"Hominidae","hmdmc_number":"new 123456","ebi_accession_number":"new accession number","sample_source":"new sample source","mother":"new mother","father":"new father","sibling":"new sibling","gc_content":"new gc content","public_name":"new public name","cohort":"new cohort","storage_conditions":"new storage conditions","date_of_sample_collection":"new 2013-06-24","is_sample_a_control":false,"is_re_submitted_sample":true,"dna":{"pre_amplified":true,"date_of_sample_extraction":"new 2013-06-02","extraction_method":"new extraction method","concentration":121,"sample_purified":true,"concentration_determined_by_which_method":"new method"},"cellular_material":{"lysed":true},"genotyping":{"country_of_origin":"new england","geographical_region":"new europe","ethnicity":"new english"}}}},"action":"bulk_update_sample","date":"2013-06-04 15:37:46 UTC","user":"user"}
        EOD
      }

        it "finds the right number of resources" do
          result.size.should == 3
        end

        it "finds the right resource models" do
          result.each do |resource|
            resource.should be_a(Model::Sample)
          end
        end
      end

      context "decode bulk delete sample message" do
        let(:action) { "deletesample" }
        let(:payload) {
         JSON.parse <<-EOD
        {"bulk_delete_sample":{"actions":{},"user":"user","application":"application","result":{"samples":[{"actions":{"read":"http://localhost:9292/a0d1f780-af5a-0130-51e4-282066132de2","create":"http://localhost:9292/a0d1f780-af5a-0130-51e4-282066132de2","update":"http://localhost:9292/a0d1f780-af5a-0130-51e4-282066132de2","delete":"http://localhost:9292/a0d1f780-af5a-0130-51e4-282066132de2"},"uuid":"a0d1f780-af5a-0130-51e4-282066132de2","state":"draft","supplier_sample_name":"new supplier sample name","gender":"Hermaphrodite","sanger_sample_id":"S2-bf54c86eb4a943e6b8967beebd750b70","sample_type":"Blood","scientific_name":"Hominidae","common_name":"great apes","hmdmc_number":"new 123456","ebi_accession_number":"new accession number","sample_source":"new sample source","mother":"new mother","father":"new father","sibling":"new sibling","gc_content":"new gc content","public_name":"new public name","cohort":"new cohort","storage_conditions":"new storage conditions","taxon_id":9604,"volume":101,"date_of_sample_collection":"2013-06-24T00:00:00+01:00","is_sample_a_control":false,"is_re_submitted_sample":true,"dna":{"pre_amplified":true,"date_of_sample_extraction":"2013-06-02T00:00:00+01:00","extraction_method":"new extraction method","concentration":121,"sample_purified":true,"concentration_determined_by_which_method":"new method"},"cellular_material":{"lysed":true},"genotyping":{"country_of_origin":"new england","geographical_region":"new europe","ethnicity":"new english"}},{"actions":{"read":"http://localhost:9292/a0d251a0-af5a-0130-51e4-282066132de2","create":"http://localhost:9292/a0d251a0-af5a-0130-51e4-282066132de2","update":"http://localhost:9292/a0d251a0-af5a-0130-51e4-282066132de2","delete":"http://localhost:9292/a0d251a0-af5a-0130-51e4-282066132de2"},"uuid":"a0d251a0-af5a-0130-51e4-282066132de2","state":"draft","supplier_sample_name":"new supplier sample name","gender":"Hermaphrodite","sanger_sample_id":"S2-85f5fbe5a99a4429a9ffdc97bf22593e","sample_type":"Blood","scientific_name":"Hominidae","common_name":"great apes","hmdmc_number":"new 123456","ebi_accession_number":"new accession number","sample_source":"new sample source","mother":"new mother","father":"new father","sibling":"new sibling","gc_content":"new gc content","public_name":"new public name","cohort":"new cohort","storage_conditions":"new storage conditions","taxon_id":9604,"volume":101,"date_of_sample_collection":"2013-06-24T00:00:00+01:00","is_sample_a_control":false,"is_re_submitted_sample":true,"dna":{"pre_amplified":true,"date_of_sample_extraction":"2013-06-02T00:00:00+01:00","extraction_method":"new extraction method","concentration":121,"sample_purified":true,"concentration_determined_by_which_method":"new method"},"cellular_material":{"lysed":true},"genotyping":{"country_of_origin":"new england","geographical_region":"new europe","ethnicity":"new english"}},{"actions":{"read":"http://localhost:9292/a0d29e20-af5a-0130-51e4-282066132de2","create":"http://localhost:9292/a0d29e20-af5a-0130-51e4-282066132de2","update":"http://localhost:9292/a0d29e20-af5a-0130-51e4-282066132de2","delete":"http://localhost:9292/a0d29e20-af5a-0130-51e4-282066132de2"},"uuid":"a0d29e20-af5a-0130-51e4-282066132de2","state":"draft","supplier_sample_name":"new supplier sample name","gender":"Hermaphrodite","sanger_sample_id":"S2-7e7f7fa17d704c0aa3b43d3f69b0e4b2","sample_type":"Blood","scientific_name":"Hominidae","common_name":"great apes","hmdmc_number":"new 123456","ebi_accession_number":"new accession number","sample_source":"new sample source","mother":"new mother","father":"new father","sibling":"new sibling","gc_content":"new gc content","public_name":"new public name","cohort":"new cohort","storage_conditions":"new storage conditions","taxon_id":9604,"volume":101,"date_of_sample_collection":"2013-06-24T00:00:00+01:00","is_sample_a_control":false,"is_re_submitted_sample":true,"dna":{"pre_amplified":true,"date_of_sample_extraction":"2013-06-02T00:00:00+01:00","extraction_method":"new extraction method","concentration":121,"sample_purified":true,"concentration_determined_by_which_method":"new method"},"cellular_material":{"lysed":true},"genotyping":{"country_of_origin":"new england","geographical_region":"new europe","ethnicity":"new english"}}]},"sample_uuids":["a0d1f780-af5a-0130-51e4-282066132de2","a0d251a0-af5a-0130-51e4-282066132de2","a0d29e20-af5a-0130-51e4-282066132de2"],"sanger_sample_ids":null},"action":"bulk_delete_sample","date":"2013-06-04 15:37:46 UTC","user":"user"}
        EOD
      }

        it "finds the right number of resources" do
          result.size.should == 3
        end

        it "finds the right resource models" do
          result.each do |resource|
            resource.should be_a(Model::Sample)
          end
        end
      end
    end


    context "Sample payload included in other S2 resource" do 
      let(:model) { "sample" }
      let(:uuid) { "11111111-2222-3333-4444-555555555555" }
      let(:user) { "user" }
      let(:ancestor_uuid) { "11111111-2222-3333-4444-666666666666" }
      let(:order_uuid) { "11111111-2222-3333-4444-777777777777" }
      let(:role) { "my role" }
      let(:pipeline) { "My pipeline" }
      let(:ancestor_type) { "tube" }
      let(:item_status) { "done" }
      let(:date) { Time.now.utc }
      let(:payload) do 
        {}.tap do |h|
          h["uuid"] = uuid
          h["date"] = date.to_s
          h["user"] = user
          h["ancestor_uuid"] = ancestor_uuid
          h["ancestor_type"] = ancestor_type
        end
      end
      let(:decoder) { described_class.new(model, payload) }
      let(:result) { decoder.call }

      it_behaves_like "a decoder"

      context "decoded resources" do
        before do
          Model.model_for("item").new(:uuid => ancestor_uuid, :status => item_status, :role => role, :order_uuid => order_uuid).save
          Model.model_for("order").new(:uuid => order_uuid, :pipeline => pipeline).save
          Model::Sample.new(:uuid => uuid).save
        end

        it "returns an array with a sample container helper model and a sample management activity model" do
          result[0].should be_a(Model::SampleContainerHelper)
          result[0].sample_uuid.should == uuid
          result[0].container_uuid.should == ancestor_uuid
          result[0].container_model.should == ancestor_type

          result[1].should be_a(Model::SampleManagementActivity)
          result[1].uuid.should == uuid
          result[1].order_uuid.should == order_uuid
          result[1].process.should == pipeline
          result[1].step.should == role
          result[1].tube_uuid.should == ancestor_uuid
          result[1].spin_column_uuid.should be_nil
          result[1].user.should == user
          result[1].status.should == item_status
          result[1].current_from.to_s.should == date.to_s
        end
      end
    end
  end
end
