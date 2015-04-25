# ActiveModel::Errors#details

[![Build Status](https://travis-ci.org/cowbell/active_model-errors_details.svg?branch=master)](https://travis-ci.org/cowbell/active_model-errors_details)

Feature backported from Rails 5.0 to use with Rails 3.2.x and 4.x apps.

Background: https://github.com/rails/rails/pull/18322

## Installation

```
gem install "active_model-errors_details"
```

## Usage

To check what validator type was used on invalid attribute, you can use `errors.details[:attribute]`. It returns array of hashes where under `:error` key you will find symbol of used validator.

```ruby
class Person < ActiveRecord::Base
  validates :name, presence: true
end

person = Person.new
person.valid?
person.errors.details[:name]
# => [{error: :blank}]
```

You can add validator type to details hash when using `ActiveModel::Errors.add` method.

```ruby
class User < ActiveRecord::Base
  validate :adulthood

  def adulthood
    errors.add(:age, :too_young) if age < 18
  end
end

user = User.new(age: 15)
user.valid?
user.errors.details
# => {age: [{error: :too_young}]}
```

To improve error details to contain additional options, you can pass them to `ActiveModel::Errors.add` method.

```ruby
class User < ActiveRecord::Base
  validate :adulthood

  def adulthood
    errors.add(:age, :too_young, years_limit: 18) if age < 18
  end
end

user = User.new(age: 15)
user.valid?
user.errors.details
# => {age: [{error: :too_young, years_limit: 18}]}
```

All built in Rails validators populate details hash with corresponding
validator types.
