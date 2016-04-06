# rooble

Yet another unnecessary and selfishly-created pagination and search gem for rails.

## Why?

Because its a fun way for me to learn rails. There are other, more complex and full featured solutions like [Kaminari](https://github.com/amatsuda/kaminari) but this works fine too.

## How?

Add this to your Gemfile:

`gem 'rooble'`

Then do the usual dance:

`bundle install`

## Using it

There are three main methods:

`Model.pages` will give you the number of available pages given that you setup the `MAX_RECORDS_PER_PAGE` env var.

`Model.paginate(1)` will give you records for the first page.

`Model.search("John", [:name])` will look for records which have **John** within the `name` attribute.

There is an extra options hash that you can pass to this method, the options are:

 * `case_sensitive: false` whether you want to make the search case sensitive. Default is false.
 * `type: all` type of match, beginning, end or the whole string. Default is all.
 * `include` an array/hash of symbols if you want to include other relations on the model. Same as with default rails include.
 * `join` an array/hash of symbols if you want to join other relations on the model. Same as with default rails join.

If you want to search for attributes in joint models you would do something like this:

`State.search("USA", "countries.name", join: [:country]).first`

Or if you want to search for the first city of the USA:

`City.search("USA", "countries.name", join: {state: :country}).first`

That would search the first state that has a country named USA. Do note the string notation for the relation.

Oh yes, you can chain the methods so you could do something like paginating search results:

`State.search("USA", "countries.name", join: [:country]).paginate(2)`

That's it for now.

## Other features

I will/may add a view helper to generate the pagination navigation and and initializer for the `MAX_RECORDS_PER_PAGE`. For now just set it yourself on your env vars.
