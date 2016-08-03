require "minitest_helper"
# Bug in rails dependencies
# https://github.com/rails/rails/pull/18619
require "active_support/core_ext/module/remove_method"
require "active_model/naming"

class TestErrorsDetails < MiniTest::Test
  class Person
    extend ActiveModel::Naming

    def initialize
      @errors = ActiveModel::Errors.new(self)
    end

    attr_accessor :name, :age
    attr_reader   :errors

    def validate
      errors.add(:name, :blank) if name == nil
      errors.add(:age, :too_young, years: 20) if age && age < 20
    end

    def read_attribute_for_validation(attr)
      send(attr)
    end

    def self.human_attribute_name(attr, options = {})
      attr
    end

    def self.lookup_ancestors
      []
    end
  end

  def test_returns_empty_array_when_no_errors
    person = Person.new
    person.name = "John"
    person.validate

    assert_empty person.errors.details[:name]
  end

  def test_adds_details
    person = Person.new
    person.validate

    assert_equal({name: [{error: :blank}]}, person.errors.details)
  end

  def test_adds_details_with_custom_value
    person = Person.new
    person.age  = 18
    person.validate

    assert_equal [{error: :too_young, years: 20}], person.errors.details[:age]
  end

  def test_do_not_include_message_option
    person = Person.new
    person.errors.add(:name, :invalid, message: "is bad")

    assert_equal({name: [{error: :invalid}] }, person.errors.details)
  end

  def test_dup_duplicates_details
    errors = ActiveModel::Errors.new(Person.new)
    errors.add(:name, :invalid)
    errors_dup = errors.dup
    errors_dup.add(:name, :taken)

    refute_equal errors_dup.details, errors.details
  end

  def test_delete_removes_details_on_given_attribute
    errors = ActiveModel::Errors.new(Person.new)
    errors.add(:name, :invalid)
    errors.delete(:name)

    assert_empty errors.details[:name]
  end

  def test_clear_removes_details
    person = Person.new
    person.errors.add(:name, :invalid)

    assert_equal 1, person.errors.details.count
    person.errors.clear

    assert_empty person.errors.details
  end

  def test_errors_are_marshalable
    errors = ActiveModel::Errors.new(Person.new)
    errors.add(:name, :invalid)
    serialized = Marshal.load(Marshal.dump(errors))

    assert_equal errors.messages, serialized.messages
    assert_equal errors.details, serialized.details
  end
end
