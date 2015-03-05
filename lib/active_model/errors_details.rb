require "active_model/errors_details/version"
require "active_model/errors"
require "active_support/core_ext/object/deep_dup"

module ActiveModel
  module ErrorsDetails
    MESSAGE_OPTIONS = [:message]

    def self.included(base)
      base.class_eval do
        alias_method :initialize_without_details, :initialize
        alias_method :initialize, :initialize_with_details

        alias_method :initialize_dup_without_details, :initialize_dup
        alias_method :initialize_dup, :initialize_dup_with_details

        alias_method :delete_without_details, :delete
        alias_method :delete, :delete_with_details

        alias_method :clear_without_details, :clear
        alias_method :clear, :clear_with_details

        alias_method :add_without_details, :add
        alias_method :add, :add_with_details
      end
    end

    def initialize_dup_with_details(other)
      @details = other.details.deep_dup
      initialize_dup_without_details(other)
    end

    def details
      @details
    end

    def initialize_with_details(base)
      @details = Hash.new { |details, attribute| details[attribute] = [] }
      initialize_without_details(base)
    end

    def delete_with_details(key)
      details.delete(key)
      delete_without_details(key)
    end

    def clear_with_details
      details.clear
      clear_without_details
    end

    def add_with_details(attribute, message = :invalid, options = {})
      message = message.call if message.respond_to?(:call)

      error = {error: message}.merge(options.except(*::ActiveModel::Errors::CALLBACKS_OPTIONS + MESSAGE_OPTIONS))
      details[attribute.to_sym] << error
      add_without_details(attribute, message, options)
    end
  end
end

ActiveModel::Errors.send(:include, ActiveModel::ErrorsDetails)
