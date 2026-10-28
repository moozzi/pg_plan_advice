# frozen_string_literal: true

require_relative "lib/pg_plan_advice/version"

Gem::Specification.new do |spec|
  spec.name = "pg_plan_advice"
  spec.version = PgPlanAdvice::VERSION
  spec.authors = ["moozzi"]
  spec.email = ["bieniek.milosz0@gmail.com"]

  spec.summary = "ActiveRecord DSL for PostgreSQL pg_plan_advice."
  spec.description = "Apply PostgreSQL 19 pg_plan_advice query plan advice to ActiveRecord queries using a simple Ruby DSL."
  spec.homepage = "https://github.com/moozzi/pg_plan_advice"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/moozzi/pg_plan_advice"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
