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

    def search(fields, search_term, options={})
      if search_term.nil?
        raise Rooble::Error.new "You need to give a search term"
      end

      if fields.nil? || fields.empty?
        raise Rooble::Error.new "You need to give at least one field to search"
      end

      raise Rooble::Error.new("You can only include or join relations, not both!") if ([:include, :join] - options.keys ).empty?

      # check if we are joining/including other models first
      if options.has_key? :include
        model = self.includes(options[:include])
      elsif options.has_key? :join
        model = self.joins(options[:join])
      else
        model = self
      end

      search_beginning = "%"
      search_end = "%"
      fields = [].push(fields) unless fields.is_a? Array
      search_values = []
      query = ''
      case_sensitive = false
      or_cond = ''

      if options.has_key? :case_sensitive
        if options[:case_sensitive]
          case_sensitive = true
        end
      end

      fields.each_with_index do |field,index|
        # set the OR if we have more than one field
        if index > 0
          or_cond = "OR"
        end

        # lets find out if we are looking for the ID, we can't
        # use like for integers so we use equality instead
        if field.downcase == "id"
          # check that the serch term is actually a number
          operator = "="
          search_values.push(search_term.to_i)
        else

          # set the type of search wether just beginning of string
          # the end or as a whole
          if options.has_key? :match_type
            case options[:match_type].to_s
            when "beginning"
              search_beginning = nil
            when "end"
              search_end = nil
            when "all"
              search_beginning = "%"
              search_end = "%"
            when "none"
              search_beginning = nil
              search_end = nil
            end
          end

          # set whether we want case sensitive search
          case ActiveRecord::Base.connection.adapter_name
          when "PostgreSQL"
            case_sensitive ? operator = "LIKE" : operator = "ILIKE"
            search_value = search_term
          when "MySQL", "Mysql2", "SQLite"
            operator = "LIKE"
            if case_sensitive
              search_value = search_term
            else
              field = "LOWER(#{field})"
              search_value = search_term.downcase
            end
          end

          # downcase the search term if we are doing case insensitive search so
          # the value of downcasing the column matches
          search_values.push("#{search_beginning}#{search_value}#{search_end}")
        end

        query += " #{or_cond} #{field} #{operator} ? "
      end

      records = model.where(query, *search_values)
    end

  end

  ActiveRecord::Base.send(:include, Rooble)
end
