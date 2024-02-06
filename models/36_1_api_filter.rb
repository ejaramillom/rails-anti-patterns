# filter implementation

# frozen_string_literal: true

module V1::ApiFilter
  class FilterControllerError < StandardError; end

  extend ActiveSupport::Concern
  included do
    def initial_filter_params(filter_params)
      valid_keys?(filter_params)

      @escaped_input = filter_params[:search_value]
                        &.split(' ')
                        &.map { |value| ActiveRecord::Base.connection.quote("%#{value}%") }
      @search_attribute = determine_search_attribute(filter_params[:search_by])
      @query = "#{@search_attribute} ILIKE ANY(ARRAY[#{@escaped_input&.join(',')}])"
      @filter_params = filter_params
    end

    def filter_by(scoped, search_by, search_value)
      return scoped if filter?(filter_params)

      scoped = filter_every_attribute(scoped, search_by, @escaped_input)
      scoped = filter_by_attribute(scoped, search_by, search_value)
      filter_by_exception(scoped, search_by, search_value)
    end

    protected

    def valid_keys?(filter_params)
      attributes_keys = attribute_mapping.merge(exception_mapping).keys
      search_by = filter_params[:search_by]
      sort_field = filter_params[:sort_field]

      if search_by.present? && !attributes_keys.include?(search_by) && filter_params[:search_by] != 'all'
        error_message = "Invalid search_by param, send one of these: [#{attributes_keys.join(', ')}]"
        raise FilterControllerError, error_message
      end

      if sort_field.present? && !attributes_keys.include?(sort_field)
        error_message = "Invalid sort_field param, send one of these: [#{attributes_keys.join(', ')}]"
        raise FilterControllerError, error_message
      end
    end

    def filter?(filter_params)
      filter_params[:search_by].blank? && filter_params[:search_value].blank?
    end

    def filter_every_attribute(scoped, search_by, search_value)
      return scoped unless all_key_present?(search_by, search_value)

      build_search_query(@escaped_input, scoped, cleansed_mapping)
    end

    def all_key_present?(search_by, search_value)
      search_value.present? && search_by == 'all'
    end

    def build_search_query(escaped_input, scoped, cleansed_mapping)
      query_part = escaped_input.map do |value|
        clauses = cleansed_mapping.map do |key, attribute|
          "#{attribute} ILIKE #{value}"
        end
        "(#{clauses.join(' OR ')})"
      end.join(' AND ')

      scoped = scoped.where(query_part) if query_part.present?
      scoped
    end

    def filter_by_attribute(scoped, search_by, search_value)
      return scoped unless attribute_present?(search_by, search_value)

      scoped.where(@query)
    end

    def attribute_present?(search_by, search_value)
      determine_search_attribute(search_by).present? &&
        search_value.present? &&
        determine_exception_attribute(search_by).blank?
    end

    def filter_by_exception(scoped, search_by, search_value)
      return scoped unless exception_present?(search_by, search_value)

      scoped.where(@search_attribute => search_value)
    end

    def exception_present?(search_by, search_value)
      determine_search_attribute(search_by).present? &&
        search_value.present? &&
        determine_exception_attribute(search_by).present?
    end

    def order_by_field(scoped, default_sort_field = :id, default_sort_direction = :asc)
      filter_params = @filter_params || {}

      unless filter_params&.dig(:sort_field) && filter_params&.dig(:sort_direction)
        return scoped.order("#{default_sort_field} #{default_sort_direction}")
      end

      sort_field = determine_search_attribute(filter_params[:sort_field])
      sort_direction = filter_params[:sort_direction]&.upcase
      scoped.order("#{sort_field} #{sort_direction}")
    end

    def pagination(scoped)
      return scoped if filter_params[:page].blank? || filter_params[:per_page].blank?

      scoped&.paginate(page: filter_params[:page], per_page: filter_params[:per_page]) if filter_params[:page].present?
    end

    def determine_search_attribute(search_by)
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def determine_exception_attribute(search_by)
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def attribute_mapping
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def exception_mapping
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def cleansed_mapping
      attribute_mapping.reject { |key, _value| exception_mapping.key?(key) }
    end
  end
end
