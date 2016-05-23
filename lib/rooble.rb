require "rooble/version"

# Main module for rooble.
module Rooble
  extend ActiveSupport::Concern

  class Configuration
    attr_accessor :max_records_per_page
  end

  class Error < StandardError
  end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
  end

  def self.build_query(search_term, fields, options={})

    # Set whether we want case sensitive search
    operator = "ILIKE"
    if options.has_key? :case_sensitive
      operator = "LIKE" if options[:case_sensitive]
    end

    search_beginning = "%"
    search_end = "%"
    if options.has_key? :type
      case options[:type]
      when "beginning"
        search_end = ""
      when "end"
        search_beginning = ""
      end
    end

    # Loop through fields and build query
    query = ""
    or_cond = ""
    fields = [].push(fields) unless fields.is_a? Array
    fields.each_with_index do |v,i|
      if i > 0
        or_cond = "OR"
      end
      query += " #{or_cond} #{v} #{operator} '#{search_beginning}#{search_term}#{search_end}' "
    end

    query
  end

  module ClassMethods
    ##
    # Returns the amount of available pages to do pagination.
    #

    def pages(max_records_per_page=nil)
      max_records_per_page ||= Rooble::configuration.max_records_per_page
      total_record_count = self.count
      return 0 unless total_record_count > 0
      pages = (total_record_count.to_f / max_records_per_page.to_f).ceil
    end

    ##
    # Returns a set of paginated records given a page.
    #

    def paginate(page=1, max_records_per_page=nil)
      page ||= 1

      if page.to_i < 0
        raise Rooble::Error.new "Pagination index must be greater than zero"
      end

      max_records_per_page ||= Rooble::configuration.max_records_per_page
      current_offset = ((page.to_i*max_records_per_page))-max_records_per_page
      records = self.limit(max_records_per_page).offset(current_offset)
    end

    ##
    # Searches through records for the given fields
    #

    def search(search_term, fields, options={})
      if search_term.nil?
        raise Rooble::Error.new "You need to give a search term"
      end

      if fields.empty?
        raise Rooble::Error.new "You need to give at least one field to search"
      end

      raise Rooble::Error.new("You can only include or join relations, not both!") if ([:include, :join] - options.keys ).empty?

      # Build the query
      query = Rooble::build_query(search_term, fields, options)

      if options.has_key? :include
        records = self.includes(options[:include]).where(query)
      elsif options.has_key? :join
        records = self.joins(options[:join]).where(query)
      else
        records = self.where(query)
      end

      records
    end
  end

  ActiveRecord::Base.send(:include, Rooble)
end
