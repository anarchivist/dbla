# -*- encoding : utf-8 -*-
module Dbla
  class Response < AbstractResponse
    autoload :Facets, 'dbla/response/facets'

    def initialize(data, request_params, options = {})
      super(force_to_utf8(data))
      @request_params = request_params
      self.document_model = options[:solr_document_model] || options[:document_model] || Item
      self.blacklight_config = options[:blacklight_config]
      if data
        @total = data['count']
        @documents = (data['docs'] || []).map {|d| document_model.new(d,self)}
        @start = data['start']
        @limit = data['limit']
        @aggregations = (data['facets'] || {})
      else
        @aggregations = {}
        @total = 0
        @start = 0
        @limit = 10
        @documents = []
      end
    end
    def aggregations
      # "facets":{"sourceResource.format":{"_type":"terms","missing":77,"total":250,"other":16,"terms":[{"term":"Photographs","count":44},
      Hash[@aggregations.map do |k,v|
        items = v['terms'].map {|term| Facets::FacetItem.new(value: term['term'], hits: term['count'])}
        [k, Facets::FacetField.new(k,items)]
      end]
    end
    def spelling
      Words.new([])
    end
    class Words
      attr_accessor :words
      def initialize(words)
        @words = words
      end
    end
  end
end