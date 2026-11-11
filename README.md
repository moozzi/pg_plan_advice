# PgPlanAdvice

ActiveRecord DSL for PostgreSQL pg_plan_advice.

> [!WARNING]
> This gem is in active development. The API may change without notice and it should not be used in production.

## Installation

Requirements:

- Ruby >= 3.2
- ActiveRecord 7.2
- PostgreSQL 19 with the `pg_plan_advice` module loaded (for example via `shared_preload_libraries`), see the [PostgreSQL documentation](https://www.postgresql.org/docs/devel/pgplanadvice.html)

Add the gem to your application's Gemfile:

```bash
bundle add pg_plan_advice
```

or install it from git:

```ruby
gem "pg_plan_advice"
```

## Usage

### ActiveRecord

Call `plan_advice` on a model or a relation and describe the advice in a block:

```ruby
Post.joins(:comments).plan_advice do
  join_order :posts, :comments
  hash_join :comments
  seq_scan :posts
end
```

The relation above runs with:

```
JOIN_ORDER(posts comments) HASH_JOIN(comments) SEQ_SCAN(posts)
```

### Groups

Use `ordered` and `unordered` to build target groups:

```ruby
Post.plan_advice do
  join_order :posts, ordered(:comments, unordered(:users, :tags))
  nested_loop_plain ordered(:comments, :users)
  foreign_join ordered(:remote_a, :remote_b)
end
# JOIN_ORDER(posts (comments {users tags})) NESTED_LOOP_PLAIN((comments users)) FOREIGN_JOIN((remote_a remote_b))
```

### Index advice

`index_scan` and `index_only_scan` take a hash of target to index name:

```ruby
Post.plan_advice do
  index_scan posts: :index_posts_on_user_id
end
# INDEX_SCAN(posts index_posts_on_user_id)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then run the tests:

```bash
bundle exec rspec
```

Run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/moozzi/pg_plan_advice/issues.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
