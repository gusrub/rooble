# rooble

Yet another unnecessary and selfishly-created pagination and search gem for rails.

 **But... Why?**

Because its a fun way for me to learn rails. There are other, more complex and full featured solutions like [Kaminari](https://github.com/amatsuda/kaminari) but this works fine too.

This gem does not use any special classes or modules, instead it will extend ActiveRecord functionality so that you can use the pagination and search methods directly in your ActiveRecord associations so you can even chain them!

## Installation and configuration

First add this to your Gemfile:

 `gem 'rooble'`

Then do the usual dance:

 `bundle install`

Finally create a configuration file by running

 `rails g rooble:config`

That will create a `config/initializers/rooble.rb` file and setup the default value for `max_records_per_page` to a sane number, you don't want to make it a high number though as it will pull that many records per page.

Please note that you can create the initializer manually if you'd like to, this is the basic template:

``` ruby
Rooble.configure do |config|
  config.max_records_per_page = 5
end
```

## Pagination

There are two methods for pagination that you can use directly to your ActiveRecord associations and models:

``` ruby
Model.pages(max_records_per_page=nil)
```

**Arguments:**

 - `max_records_per_page` overrides the default value and sets how many records to divide per page

`Model.pages` without any parameters will give you the number of available pages considering the `max_records_per_page` default. You can override it and pass the number of max records that should be counted per page so you get the total count of pages for such number doing something like `Model.pages(10)` if you want the count of pages with 10 records per page.

For instance given that we have a `states` table with the 48 _contiguous_ US states and our `max_records_per_page` is set to `10`:

``` ruby
 State.pages
 # => 5
```

We can override the `max_records_per_page` as well on the first argument which is optional so we get a count of pages for a diferent amount of records per page:

``` ruby
 State.pages(20)
 # => 3
```

``` ruby
Model.paginate(page=1, max_records_per_page=nil)
```

 **Arguments:**

 - `page` the page to pull records from
 - `max_records_per_page` how many records to generate per page, this overrides the initializer option

`Model.paginate` will pull records for the first page. The first argument is the page number and you can also override the `max_records_per_page` config option on the second argument so that you paginate a specific page with a different amount of max records, for instance:

``` ruby
 State.paginate
 # => pulls 10 records corresponding to the 1st page
```

``` ruby
 State.paginate(2)
 # => pulls 10 records corresponding to the 2nd page
```

``` ruby
 State.paginate(2, 5)
 # => pulls only 5 records corresponding to the 2nd page
```

Note that in the 3rd example we override the `max_records_per_page` so we will get more pages since we lowered the number of records.

## Search

The search method will lookup for keyword matches within columns or records that match a given id, this means that you can essentially use it only to search in text fields or in the primary key. So for instance if you try to search against numeric columns it won't work but for that type of specific search you are better off using ActiveRecord directly. The rational behind this is that most application _open_ searches will lookup for id's, names or codes, rarely against numeric values.

``` ruby
Model.search(fields, search_term, options={})
```

 **Arguments:**

 - `fields` a string with a field name or string array with field names to make the query against
 - `search_term` string with the term to search
 - `options` a hash with a set of options. Please se below for more info.

`Model.search("name", "John")` will look for records which have **John** within the `name` attribute.

There is an extra options hash that you can pass to this method, the options are:

 * `case_sensitive: false` whether you want to make the search case sensitive. Default is false. Note that this relies on the database engine defaults so if the column or table schema is set to be case insensitive it won't mater what you set here.
 * `match_type: all` type of match, `beginning`, `end`, `all` string or `none`. Default is all.
 * `include` an array/hash of symbols if you want to include other relations on the model. Same as with default rails include.
 * `join` an array/hash of symbols if you want to join other relations on the model. Same as with default rails join.

**Examples**

Simple search for a specific state:

``` ruby
 State.search("name", "California")
 # => Yields 1 result
```

Searching for substrings:

``` ruby
 State.search("name", "New")
 # => Yields 4 results: New Mexico, New Jersey, New Hampshire, New York
```

Searching for patterns:

``` ruby
 State.search("name", "Ma", match_type: :beginning)
 # => Yields 3 results where the value starts with Ma: Maine, Maryland and Massachusetts
```

``` ruby
 State.search("name", "Ma", match_type: :end)
 # => Yields 2 results where the value ends with ma: Alabama, Oklahoma
```

Searching in several fields

``` ruby
 State.search(["id", "name"], "California")
 # => Yields 1 result which is California
```

The above may not make much sense right? But what happens if you want your users to be able to search from a simple input or search box and allow them to either search states by name or the id? Bingo!:

``` ruby
 State.search(["id", "name"], 4)
 # => Yields 1 result which is California
```

This means that you can allow input for both id's or text and still try to filter by either, you just pass on the second argument whatever input you get from the user.

Now lets do a more complicated search. Say you want to search for attributes in joint models, like searching for the first state where the country name is "USA":

``` ruby
 State.search("countries.name", "USA", join: [:country]).first
```

Do note the string notation for the relation.

You can even do multi-level joins, for instance if you want to search for the first city of the USA:

``` ruby
City.search("countries.name", "USA", join: {state: :country}).first
```

Oh yes, you can chain the methods so you could do something like paginating search results:

``` ruby
State.search("countries.name", "USA", join: [:country]).paginate(2)
```

That's it for now.

## Other features

I will/may add a rails view helper to generate the pagination navigation.
