require "active_model/errors_details/version"
require "active_model/errors"

begin
  require "active_support/core_ext/object/deep_dup"
rescue LoadError
  # Rails 3.2 compatibility
  require "active_support/core_ext/object/duplicable"

  class Object
    def deep_dup
      duplicable? ? dup : self
    end
  end

  class Array
    def deep_dup
      map(&:deep_dup)
    end
  end

  class Hash
    def deep_dup
      each_with_object(dup) do |(key, value), hash|
        hash[key.deep_dup] = value.deep_dup
      end
    end
  end
end

if defined?(ActiveRecord)
  require "active_record/autosave_association"

  module ActiveRecord
    module AutosaveAssociation
      def association_valid?(reflection, record)
        return true if record.destroyed? || (reflection.options[:autosave] && record.marked_for_destruction?)

        validation_context = self.validation_context unless [:create, :update].include?(self.validation_context)
        unless valid = record.valid?(validation_context)
          if reflection.options[:autosave]
            record.errors.each do |attribute, message|
              attribute = "#{reflection.name}.#{attribute}"
              errors[attribute] << message
              errors[attribute].uniq!
            end
            # Monkey patch here
            record.errors.details.each_key do |attribute|
              reflection_attribute = "#{reflection.name}.#{attribute}"

              record.errors.details[attribute].each do |error|
                errors.details[reflection_attribute] << error
                errors.details[reflection_attribute].uniq!
              end
            end
          else
            errors.add(reflection.name)
          end
        end
        valid
      end
    end
  end
end

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

    def marshal_dump
      [@base, without_default_proc(@messages), without_default_proc(@details)]
    end

    def marshal_load(array)
      @base, @messages, @details = array
      apply_default_array(@messages)
      apply_default_array(@details)
    end

    private

    def without_default_proc(hash)
      hash.dup.tap do |new_h|
        new_h.default_proc = nil
      end
    end

    def apply_default_array(hash)
      hash.default_proc = proc { |h, key| h[key] = [] }
      hash
    end
  end
end

ActiveModel::Errors.send(:include, ActiveModel::ErrorsDetails)
