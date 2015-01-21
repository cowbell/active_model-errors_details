# ActiveModel::Errors#details

Feature backported from Rails 5.0 to use with Rails 4.x apps.

Background: https://github.com/rails/rails/pull/18322

## Installation

```
gem install "active_model-errors_details"
```

## Usage

To check what validator type was used on invalid attribute, you can use
`errors.details[:attribute]`. It returns array of hashes where under `:error`
 key you will find symbol of used validator.

```ruby
class Person < ActiveRecord::Base
  validates :name, presence: true
end

>> person = Person.new
>> person.valid?
>> person.errors.details[:name] #=> [{error: :blank}]
```

You can add validator type to details hash when using `errors.add` method.

```ruby
class Person < ActiveRecord::Base
  def a_method_used_for_validation_purposes
    errors.add(:name, :invalid_characters)
  end
end

person = Person.create(name: "!@#")

person.errors.details[:name]
 # => [{error: :invalid_characters}]
```

To improve error details to contain not allowed characters set, you can
pass additional options to `errors.add` method.

```ruby
class Person < ActiveRecord::Base
  def a_method_used_for_validation_purposes
    errors.add(:name, :invalid_characters, not_allowed: "!@#%*()_-+=")
  end
end

person = Person.create(name: "John!")

person.errors.details[:name]
# => [{error: :invalid_characters, not_allowed: "!@#%*()_-+="}]
```

All built in Rails validators populate details hash with corresponding
validator types.
