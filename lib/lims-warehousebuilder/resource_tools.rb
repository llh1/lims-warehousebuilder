require 'facets'

module Lims::WarehouseBuilder
  module ResourceTools
    module Mapping
      def self.included(klass)
        klass.extend ClassMethods
        default_mapping(klass)
      end

      def self.default_mapping(klass)
        klass.translate(:date => :created_at, :user => :created_by)
        klass.ignore(:created_at, :created_by, :updated_at, :updated_by)
      end

      module ClassMethods
        attr_reader :translations
        attr_reader :ignoreable
        def translate(h = {})
          @translations ||= {}
          @translations.merge!(h)
        end

        def ignore(*args)
          @ignoreable ||= []
          args.each { |arg| @ignoreable << arg }
        end
      end
    end


    module Database
      CURRENT_TABLES = DB.tables.keep_if { |t| t =~ /current/ }.map(&:to_s)
      HISTORIC_TABLES = DB.tables.keep_if { |t| t =~ /historic/ }.map(&:to_s)
      MODEL_TABLES = CURRENT_TABLES.map { |t| t.sub(/current_/, '') }
      S2_MODELS = MODEL_TABLES.clone.keep_if { |t| t =~ /^.*s$/ }.map { |m| m[0, m.size - 1] }
    end


    module NestedHash
      # @param [Hash] h
      # @param [String] path
      # @return [String]
      # Given a hash (could be nested) and a path into
      # the hash, return the value at the path position.
      # @example
      # h = {:a => 1, :b => {:c => 2}}
      # path = "b__c"
      # seek(h, path) => 2
      def seek(h, path)
        path_array = path.to_s.split(/__/)
        last_level = h
        value = nil

        path_array.each_with_index do |key, index|
          last_level.rekey! { |k| k.to_s } if last_level
          if last_level.is_a?(Hash) && last_level.has_key?(key)
            if index + 1 == path_array.size
              value = last_level[key]
            else
              last_level = last_level[key]
            end
          end
        end
        value
      end
    end
  end
end
