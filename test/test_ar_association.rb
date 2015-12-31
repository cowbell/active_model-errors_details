require "active_record"
require "minitest_helper"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :users, force: true  do |t|
  end

  create_table :comments, force: true  do |t|
    t.integer :user_id
    t.string :content
  end
end

class TestArAssociation < MiniTest::Test
  class User < ActiveRecord::Base
    has_many :comments

    accepts_nested_attributes_for :comments
  end

  class Comment < ActiveRecord::Base
    belongs_to :user

    validates :content, presence: true
  end

  def test_error_details_on_associated_model
    user = User.new
    user.comments.build
    user.valid?

    expected = {"comments.content" => [{error: :blank}]}
    assert_equal user.errors.details, expected
  end
end
