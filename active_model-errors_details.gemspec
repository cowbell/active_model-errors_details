# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_model/errors_details/version'

Gem::Specification.new do |spec|
  spec.name          = "active_model-errors_details"
  spec.version       = ActiveModel::ErrorsDetails::VERSION
  spec.authors       = ["Wojciech Wnętrzak"]
  spec.email         = ["w.wnetrzak@gmail.com"]
  spec.summary       = %q{Adds ActiveModel::Errors#details to return type of used validator}
  spec.description   = %q{Backported from Rails 5.0 to use with 4.x versions}
  spec.homepage      = "https://github.com/cowbell/active_model-errors_details"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activemodel", ">= 3.2.13", "< 5.0.0"
  spec.add_dependency "activesupport"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "minitest", ">= 5.6"
  spec.add_development_dependency "rake", ">= 10.0"
  spec.add_development_dependency "activerecord", ">= 3.2.13", "< 5.0.0"
  spec.add_development_dependency "sqlite3"
end
