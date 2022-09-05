# ActiveManageable

![Build Status](https://github.com/CircleSD/active_manageable/actions/workflows/ci.yml/badge.svg?branch=main)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

ActiveManageable provides a framework from which to create business logic "manager" classes in your Ruby on Rails application. Thus extending the MVC pattern to incorporate a business logic layer that sits between the controllers and models.

Moving your busines logic into a separate layer provides benefits including:

1. skinny controllers & models
2. reusable code that reduces duplication across application & API controllers and background jobs
3. isolated unit tests for the business logic, allowing system & integration tests to remain true to their purpose of testing user interaction and the workflow of the application
4. clear separation of concerns with controllers responsible for managing requests, views dealing with presentation and models handling attribute level validation and persistence
5. clear & consistent interface

ActiveManageable business logic manager classes

1. include methods for the seven standard CRUD actions: index, show, new, create, edit, update, and destroy
2. can be configured to incorporate authentication, search and pagination logic
3. enable specification of the associations to eager load, default attribute values, scopes & order when retrieving records and more
4. perform advanced parsing of parameter values for date/datetime/numeric attributes

To show how ActiveManageable manager classes can be used to create DRY code in skinny controllers, we’ll refactor the following controller index method that retrieves records with an eager loaded association using Pundit, Ransack & Kaminari.

```ruby
def index
  search = policy_scope(User).ransack(params[:q])
  search.sorts = "name asc" if q.sorts.empty?
  authorize(User)
  @users = search.result.includes(:address).page(params[:page])
end
```

With ActiveManageable configured to use the Pundit, Ransack & Kaminari libraries, the following manager class includes the standard CRUD methods and sets the default order and association to eager load in the index method.

```ruby
class UserManager < ActiveManageable::Base
  manageable ActiveManageable::ALL_METHODS
  default_order :name
  default_includes :address, methods: :index
end
```

Using the manager class, the controller index method can now be rewritten to only include a single call to the index method.

```ruby
def index
  @users = UserManager.new.index(options: {search: params[:q], page: {number: params[:page]}})
end
```

The manager classes provide standard implementations of the seven core CRUD methods. These can be overwritten to perform custom business logic and the classes can also be extended to include the business logic for additional actions, both making use of the internal ActiveManageable methods and variables described in the [Adding Bespoke Methods](#adding-bespoke-methods) section.

With an Activity model in a CRM application to manage meetings & tasks, a complete action may be required. This could be implemented as follows:

```ruby
class ActivityManager < ActiveManageable::Base
  manageable ActiveManageable::ALL_METHODS

  def complete(id:)
    initialize_state
    @target = model_class.find(id)
    authorize(record: @target, action: :complete?)
    @target.update(completed_by: current_user.id, completed_at: Time.zone.now)
  end
end
```

The controller method can then call the manager method, retrieve the activity that was completed and act on the result.

```ruby
def complete
  result = manager.complete(id: params[:id])
  @activity = manager.object
  # now redirect based on the result
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_manageable'
```

And then execute:

```ruby
bundle install
```

Or install it yourself as:

```ruby
gem install active_manageable
```

## Table of Contents

- [Configuration](#configuration)
- [Current User](#current-user)
- [Authorization](#authorization)
- [Class Definition](#class-definition)
  - [Manageable Method](#manageable-method)
  - [Default Includes](#default-includes)
  - [Default Attribute Values](#default-attribute-values)
  - [Default Select](#default-select)
  - [Default Order](#default-order)
  - [Default Scopes](#default-scopes)
  - [Unique Search](#unique-search)
  - [Default Page Size](#default-page-size)
  - [Current Method](#current-method)
- [Index Method](#index-method)
  - [Authorization Scope](#index-authorization-scope)
  - [Search Option](#index-search-option)
  - [Page Option](#index-page-option)
  - [Order Option](#index-order-option)
  - [Scopes Option](#index-scopes-option)
  - [Includes Option](#index-includes-option)
  - [Select Option](#index-select-option)
  - [Distinct](#index-distinct)
- [Show Method](#show-method)
  - [Includes Option](#show-includes-option)
  - [Select Option](#show-select-option)
- [New Method](#new-method)
- [Create Method](#create-method)
- [Edit Method](#edit-method)
  - [Includes Option](#edit-includes-option)
- [Update Method](#update-method)
  - [Includes Option](#update-includes-option)
- [Destroy Method](#destroy-method)
  - [Includes Option](#destroy-includes-option)
- [Attribute Value Parsing](#attribute-value-parsing)
  - [Date and DateTime Attribute Values](#date-and-datetime-attribute-values)
  - [Numeric Attribute Values](#numeric-attribute-values)
- [ActiveManageable Attributes](#activemanageable-attributes)
- [Adding Bespoke Methods](#adding-bespoke-methods)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)

## Configuration

Create an initializer to configure the optional authorization, search and pagination libraries to use.

```ruby
ActiveManageable.config do |config|
  config.authorization_library = :pundit # or :cancancan
  config.search_library = :ransack
  config.pagination_library = :kaminari
end
```

When eager loading associations the `includes` method is used by default but this can be changed via a configuration option that accepts `:includes`, `:preload` or `:eager_load`

```ruby
ActiveManageable.config do |config|
  config.default_loading_method = :preload
end
```

ActiveManageable will attempt to determine the model class to use based on the class name and `subclass_suffix` configuration option. So if the class is named "AlbumManager" and an `Album` constant exists that will be used as the model class. If you want to use a suffix other than "Manager", the configuration option can be changed or alternatively each class can specify the model class to use when calling the `manageable` method.

```ruby
ActiveManageable.config do |config|
  config.subclass_suffix = "Concern"
end
```

```ruby
class BusinessLogic < ActiveManageable::Base
  manageable ActiveManageable::ALL_METHODS, model_class: Album
end
```

## Current User

ActiveManageable uses its own `current_user` per-thread module attribute when performing authorization with one of the configuration libraries. This needs to be set before using its methods, for example in an `ApplicationController` filter.

```ruby
around_action :setup_request

def setup_request
  ActiveManageable.current_user = current_user
  yield
  ActiveManageable.current_user = nil
end
```

The `current_user` can also be set or overridden for a block using the `with_current_user` method.

```ruby
manager = AlbumManager.new
manager.with_current_user(user) do
  manager.show(id: 1)
end
```

And is accessible via an instance method.

```ruby
manager = AlbumManager.new
manager.current_user
```

## Authorization

When using one of the configuration authorization libraries, each of the methods will perform authorization for the current user, method and either model class or record. If authorization fails an exception will be raised so you may choose to rescue the relevant exception.

Pundit - `Pundit::NotAuthorizedError`

CanCanCan - `CanCan::AccessDenied`

## Class Definition

### Manageable Method

Create a class that inherits from `ActiveManageable::Base` then use the `manageable` method to specify which methods should be included. Use the `ActiveManageable::ALL_METHODS` constant to include all methods (ie. :index, :show, :new, :create, :edit, :update and :destroy) or pass the required method name symbol(s).

```ruby
class AlbumManager < ActiveManageable::Base
  manageable ActiveManageable::ALL_METHODS
end
```

```ruby
class SongManager < ActiveManageable::Base
  manageable :index, :show
end
```

### Default Includes

The `default_includes` method sets the default associations to eager load when fetching records in the index, show, edit, update and destroy methods. These defaults are only used if the `:options` argument for those methods does not contain a `:includes` key.

```ruby
class AlbumManager < ActiveManageable::Base
  manageable ActiveManageable::ALL_METHODS
  default_includes :songs
end
```

It accepts a single, array or hash of association names, optional `:methods` in which to eager load the associations and optional `:loading_method` if this needs to be different to the configuration `:default_loading_method`. It also accepts a lambda/proc to execute to return associations with  optional `:methods`.

```ruby
default_includes :songs, :artist, methods: [:index, :show]
default_includes songs: :artist, loading_method: :preload, methods: [:edit, :update]
default_includes -> { destroy_includes }, methods: :destroy

def destroy_includes
  [:songs, {artist: :songs}]
end
```

### Default Attribute Values

The `default_attribute_values` the default attribute values to use when building a model object in the new and create methods. These defaults are combined with the attribute values from `:attributes` argument for those methods. When default and argument values contain the same attribute key, the value from the argument is used.

```ruby
class AlbumManager < ActiveManageable::Base
  manageable ActiveManageable::ALL_METHODS
  default_attribute_values genre: "pop"
end
```

It accepts either a hash of attribute values or a lambda/proc to execute to return a hash of attribute values and optional `:methods` in which in which to use the attribute values.

```ruby
default_attribute_values genre: "pop", released_at: Date.current, methods: :new
default_attribute_values -> { create_attrs } , methods: :create

def create_attrs
  {genre: "electronic", published_at: Date.current}
end
```

### Default Select

The `default_select` method sets the attributes to return in the SELECT statement used when fetching records in the index, show and edit methods. These defaults are only used if the `:options` argument for those methods does not contain a `:select` key.

```ruby
class AlbumManager < ActiveManageable::Base
  manageable ActiveManageable::ALL_METHODS
  default_select :id, :name
end
```

It accepts either an array of attribute names or a lambda/proc to execute to return an array of attribute names and optional `:methods` in which to use the attributes.

```ruby
default_select :id, :name, :genre, methods: :show
default_select -> { select_attributes }, methods: [:index, :edit]

def select_attributes
  [:id, :name, :genre, :released_at]
end
```

### Default Order

The `default_order` method sets the default order to use when fetching records in the index method. These defaults are only used if the `:options` argument for the method does not contain an `:order` key.

```ruby
class AlbumManager < ActiveManageable::Base
  manageable ActiveManageable::ALL_METHODS
  default_order :name
end
```

It accepts attributes in the same formats as the `ActiveRecord` order method or a lambda/proc to execute to return attributes in the recognised formats.

```ruby
default_order "name DESC"
```

```ruby
default_order [:name, :id]
```

```ruby
default_order -> { order_attributes }

def order_attributes
  ["name DESC", "id"]
end
```

### Default Scopes

The `default_scopes` method sets the default scope(s) to use when fetching records in the index method. These defaults are only used if the `:options` argument for the method does not contain a `:scopes` key.

```ruby
class AlbumManager < ActiveManageable::Base
  manageable ActiveManageable::ALL_METHODS
  default_scopes :electronic
end
```

It accepts a scope name, a hash containing scope name and argument, or an array of names/hashes. It also accepting a lambda/proc to execute to return a scope name, hash or array.

```ruby
default_scopes {released_in_year: "1980"}
```

```ruby
default_scopes :rock, :electronic, {released_in_year: "1980"}
```

```ruby
default_scopes -> { index_scopes }

def index_scopes
  [:rock, :electronic]
end
```

### Unique Search

The `has_unique_search` method specifies whether to use the distinct method when fetching records in the index method.

```ruby
class AlbumManager < ActiveManageable::Base
  manageable ActiveManageable::ALL_METHODS
  has_unique_search
end
```

It accepts no argument to always return unique records or a hash with :if or :unless keyword and a method name or lambda/proc to execute each time the index method is called.

```ruby
has_unique_search if: :method_name
```

```ruby
has_unique_search unless: -> { lambda }
```

### Default Page Size

When using the [Kaminari](https://github.com/kaminari/kaminari) pagination library, the `default_page_size` method sets default page size to use when fetching records in the index method. The default is only used if the `:options` argument for the method does not contain a `:page` hash with a `:size` key.

```ruby
class AlbumManager < ActiveManageable::Base
  manageable ActiveManageable::ALL_METHODS
  default_page_size 5
end
```

### Current Method

ActiveManageable includes a `current_method` attribute which returns the name of the method being executed as a symbol, which can potentially be used within methods in conjunction with a lambda for the default methods described above. Additionally, the method argument `options` and `attributes` are also accessible as attributes.

```ruby
default_includes -> { method_includes }

def method_includes
  case current_method
  when :index
    {songs: :artist}
  when :show
    [:label, :songs]
  when :edit, :update
    options.key?(:xyz) ? [:label, songs: :artists] : [:label, :songs]
  else
    :songs
  end
end
```

## Index Method

The `index` method has an optional `options` keyword argument. The `options` hash can contain `:search`, `:order`, `:scopes`, `:page`, `:includes` and `:select` keys. The method performs authorization for the current user, method and model class using the configuration library; retrieves record using the various options described below; and returns the records which are also accessible via the `collection` attribute.

```ruby
manager.index
```

### Index Authorization Scope

When using one of the configuration authorization libraries, the method retrieves records that the current user is authorized to access. For the Pundit authorization library, the method retrieves records filtered using the model's [policy scope](https://github.com/varvet/pundit#scopes). For the CanCanCan authorization library, the method retrieves records filtered using the [accessible_by scope](https://github.com/CanCanCommunity/cancancan/blob/develop/docs/fetching_records.md) for the current user's ability.

### Index Search Option

When using the [Ransack](https://github.com/activerecord-hackery/ransack) search library, the `options` argument `:search` key is used to set the Ransack filter and sorting. If either the `:search` key or its sorts `:s` key is not present, the method will order the records using the standard approach described below. The Ransack search object is accessible via the `ransack` attribute.

```ruby
manager.index(options: {search: {artist_id_eq: 1, s: "name ASC"}})
ransack_search = manager.ransack
```

### Index Page Option

When using the [Kaminari](https://github.com/kaminari/kaminari) pagination library, the `options` argument `:page` hash is used to set the page number and size of records to retrieve. The page number is set using the `:number` key value and page size is set using the `:size` key value. If the `:size` key is not present, the class default is used and if a class default has not been set then the Kaminari application default is used.

```ruby
manager.index(options: {page: {number: 2, size: 10}})
```

### Index Order Option

The `options` argument `:order` key provides the ability to specify the order in which to retrieve records and accepts attributes in the same formats as the `ActiveRecord` `order` method. When the `:order` key is not present, any class defaults are used.

```ruby
manager.index(options: {order: "name DESC"})
```

### Index Scopes Option

The `options` argument `:scopes` key provides the ability to specify the scopes to use when retrieving records and accepts a scope name, a hash containing scope name and argument, or an array of names/hashes. When the `:scopes` key is not present, any class defaults are used.

```ruby
manager.index(options: {scopes: :electronic})
```

```ruby
manager.index(options: {scopes: {released_in_year: "1980"}})
```

```ruby
manager.index(options: {scopes: [:rock, :electronic, {released_in_year: "1980"}]})
```

### Index Includes Option

The `options` argument `:includes` key provides the ability to specify associations to eager load and accepts associations names in the same formats as the AR `includes` method eg. a single association name, an array of names or a hash of names. When the `:includes` key is not present, any class defaults are used.

```ruby
manager.index(options: {includes: [:artist, :songs]})
```

The `:includes` key can also be used to vary the method used to eager load associations by providing `:associations` and `:loading_method` keys. When the `:loading_method` key is not present the method will use either the class default method (set using `default_includes`) or the configuration `default_loading_method`.

```ruby
manager.index(options: {includes: {associations: :songs, loading_method: :preload}})
```

### Index Select Option

The `options` argument `:select` key provides the ability to limit the attributes returned in the SELECT statement. When the `:select` key is not present, any class defaults are used.

```ruby
manager.index(options: {select: [:id, :name, :artist_id, :released_at]})
```

### Index Distinct

If the class `has_unique_search` method has been used then this will be evaluated to determine whether to use the distinct method when fetching the records.

## Show Method

The `show` method has `id` and optional `options` keyword arguments. The `options` hash can contain `:includes` and `:select` keys. The method retrieves a record; performs authorization for the current user, method and record using the configuration library; and returns the record which is also accessible via the `object` attribute.

```ruby
manager.show(id: 1)
```

### Show Includes Option

The `options` argument `:includes` key provides the ability to specify associations to eager load and accepts associations names in the same formats as the AR `includes` method eg. a single association name, an array of names or a hash of names. When the `:includes` key is not present, any class defaults are used.

```ruby
manager.show(id: 1, options: {includes: [:artist, :songs]})
```

The `:includes` key can also be used to vary the method used to eager load associations by providing `:associations` and `:loading_method` keys. When the `:loading_method` key is not present the method will use either the class default method (set using `default_includes`) or the configuration `default_loading_method`.

```ruby
manager.show(id: 1, options: {includes: {associations: :songs, loading_method: :preload}})
```

### Show Select Option

The `options` argument `:select` key provides the ability to limit the attributes returned in the SELECT statement. When the `:select` key is not present, any class defaults are used.

```ruby
manager.show(id: 1, options: {select: [:id, :name, :artist_id, :released_at]})
```

## New Method

The `new` method has an optional `attributes` keyword argument. The `attributes` argument is for an `ActionController::Parameters` or hash of attribute names and values to use when building the record. The method builds a record; performs authorization for the current user, method and record using the configuration library; and returns the record which is also accessible via the `object` attribute.

```ruby
manager.new
```

The `attributes` argument values are combined with the class default values and when the default and argument values contain the same attribute key, the value from the argument is used.

```ruby
manager.new(attributes: {genre: "electronic", published_at: Date.current})
```

## Create Method

The `create` method has an `attributes` keyword argument. The `attributes` argument is for an `ActionController::Parameters` or hash of attribute names and values to use when building the record. The method builds a record; performs authorization for the current user, method and record using the configuration library; attempts to save the record and returns the save result. The record is also accessible via the `object` attribute.

```ruby
manager.create(attributes: {name: "Substance", genre: "electronic", published_at: Date.current})
```

The `attributes` argument values are combined with the class default values and when the default and argument values contain the same attribute key, the value from the argument is used.

## Edit Method

The `edit` method has `id` and optional `options` keyword arguments. The `options` hash can contain `:includes` and `:select` keys. The method retrieves a record; performs authorization for the current user, method and record using the configuration library; and returns the record which is also accessible via the `object` attribute.

```ruby
manager.edit(id: 1)
```

### Edit Includes Option

The `options` argument `:includes` key provides the ability to specify associations to eager load and accepts associations names in the same formats as the AR `includes` method eg. a single association name, an array of names or a hash of names. The `:select` key provides the ability to limit the attributes returned in the SELECT statement. When the `:includes` and `:select` keys are not present, any class defaults are used.

```ruby
manager.edit(id: 1, options: {includes: [:artist, :songs], select: [:id, :name, :artist_id, :released_at]})
```

The `:includes` key can also be used to vary the method used to eager load associations by providing `:associations` and `:loading_method` keys. When the `:loading_method` key is not present the method will use either the class default method (set using `default_includes`) or the configuration `default_loading_method`.

```ruby
manager.edit(id: 1, options: {includes: {associations: :songs, loading_method: :preload}})
```

## Update Method

The `update` method has `id`, `attributes` and optional `options` keyword arguments. The `attributes` argument is for an `ActionController::Parameters` or hash of attribute names and values to use when updating the record. The `options` hash can contain an `:includes` key. The method retrieves a record; performs authorization for the current user, method and record using the configuration library; updates the attributes; attempts to save the record and returns the save result. The record is also accessible via the `object` attribute.

```ruby
manager.update(id: 1, attributes: {genre: "electronic", published_at: Date.current})
```

### Update Includes Option

The `options` argument `:includes` key provides the ability to specify associations to eager load and accepts associations names in the same formats as the AR `includes` method eg. a single association name, an array of names or a hash of names. When the `:includes` key is not present, any class defaults are used.

```ruby
manager.update(id: 1, attributes: {published_at: Date.current}, options: {includes: [:artist]})
```

The `:includes` key can also be used to vary the method used to eager load associations by providing `:associations` and `:loading_method` keys. When the `:loading_method` key is not present the method will use either the class default method (set using `default_includes`) or the configuration `default_loading_method`.

```ruby
manager.update(id: 1, attributes: {published_at: Date.current}, options: {includes: {associations: :songs, loading_method: :preload}})
```

## Destroy Method

The `destroy` method has `id` and optional `options` keyword arguments. The `options` hash can contain an `:includes` key. The method retrieves a record; performs authorization for the current user, method and record using the configuration library; attempts to destroy the record and returns the destroy result. The record is accessible via the `object` attribute.

```ruby
manager.destroy(id: 1)
```

### Destroy Includes Option

The `options` argument `:includes` key provides the ability to specify associations to eager load and accepts associations names in the same formats as the AR `includes` method eg. a single association name, an array of names or a hash of names. When the `:includes` key is not present, any class defaults are used.

```ruby
manager.destroy(id: 1, options: {includes: [:artist]})
```

The `:includes` key can also be used to vary the method used to eager load associations by providing `:associations` and `:loading_method` keys. When the `:loading_method` key is not present the method will use either the class default method (set using `default_includes`) or the configuration `default_loading_method`.

```ruby
manager.destroy(id: 1, options: {includes: {associations: :songs, loading_method: :preload}})
```

## Attribute Value Parsing

### Date and DateTime Attribute Values

If you have users in the US where the date format is month/day/year you'll be aware that `ActiveRecord` does not support that string format. The issue is further complicated if you also have users in other countries that use the day/month/year format.

```ruby
I18n.locale = :"en-US"
Album.new(published_at: "12/22/2022 14:21").published_at # => nil
```

ActiveManageable caters for these different formats and provides greater flexibility to accept a wider variety of formats by parsing date and datetime values using the [Flexitime gem](https://github.com/CircleSD/flexitime) before setting a model object's attribute values. Flexitime uses the [rails-i18n gem](https://github.com/svenfuchs/rails-i18n) to determine whether the first date part is day or month and then returns an ActiveSupport [TimeZone](https://api.rubyonrails.org/classes/ActiveSupport/TimeZone.html) object. ActiveManageable updates the `attributes` argument for the new, create and update methods to replace the value for any attributes with a data type of date or datetime and also updates the attributes values for any associations within the attributes hash.

```ruby
I18n.locale = :"en-US"
ActiveManageable.current_user = User.first
manager = AlbumManager.new
manager.new(attributes: {published_at: "12/01/2022 14:21", songs_attributes: [{published_at: "12/01/2022 14:21"}]})
manager.object.published_at              # => Thu, 01 Dec 2022 14:21:00.000000000 UTC +00:00
manager.object.songs.first.published_at  # => Thu, 01 Dec 2022 14:21:00.000000000 UTC +00:00
manager.attributes                       # => {"published_at"=>Wed, 12 Jan 2022 14:21:00.000000000 UTC +00:00, ... }]}
```

```ruby
I18n.locale = :"en-GB"
ActiveManageable.current_user = User.first
manager = AlbumManager.new
manager.new(attributes: {published_at: "12/01/2022 14:21", songs_attributes: [{published_at: "12/01/2022 14:21"}]})
manager.object.published_at              # => Wed, 12 Jan 2022 14:21:00.000000000 UTC +00:00
manager.object.songs.first.published_at  # => Wed, 12 Jan 2022 14:21:00.000000000 UTC +00:00
manager.attributes                       # => {"published_at"=>Wed, 12 Jan 2022 14:21:00.000000000 UTC +00:00, ... }]}
```

By default, the [Flexitime gem](https://github.com/CircleSD/flexitime) `parse` method returns time objects with a minute precision so to persist datetime values with seconds or milliseconds it is necessary to set the Flexitime configuration option accordingly.

```ruby
ActiveManageable.current_user = User.first
manager = AlbumManager.new
manager.new(attributes: {published_at: "12/01/2022 14:21:45"})
manager.object.published_at # => Wed, 12 Jan 2022 14:21:00.000000000 UTC +00:00

Flexitime.precision = :sec
manager.new(attributes: {published_at: "12/01/2022 14:21:45"})
manager.object.published_at # => Wed, 12 Jan 2022 14:21:45.000000000 UTC +00:00
```

### Numeric Attribute Values

If you have users in the Netherlands or other countries that use a comma number separator then you ideally want to allow them to enter numeric values using that separator rather than a point separator. Unfortunately `ActiveRecord` does not support such a separator when setting attributes values.

```ruby
I18n.locale = :nl
Album.new(length: "6,55").length.to_s # => "6.0"
```

ActiveManageable caters for the comma number separator by replacing the comma with a point before setting a model object's attribute values. It uses the [rails-i18n gem](https://github.com/svenfuchs/rails-i18n) to determine if the locale number separator is a comma. It then updates the `attributes` argument for the new, create and update methods to replace the comma for any attributes with a data type of decimal or float and a value that contains only a single comma and no points. It also updates the attributes values for any associations within the attributes hash.

```ruby
I18n.locale = :nl
ActiveManageable.current_user = User.first
manager = AlbumManager.new
manager.new(attributes: {length: "6,55", songs_attributes: [{length: "8,3"}]})
manager.object.length.to_s              # => "6.55"
manager.object.songs.first.length.to_s  # => "8.3"
manager.attributes                      # => {"length"=>"6.55", "songs_attributes"=>[{"length"=>"8.3"}]}
```

## ActiveManageable Attributes

ActiveManageable includes the following attributes:

`object` - the record from the show, new, create, edit, update and destroy methods

`collection` - the records retrieved by the index method

`current_method` - the name of the method being executed as a symbol eg. `:show`

`attributes` - an `ActiveSupport::HashWithIndifferentAccess` representation of the argument from the new, create and update methods (in the case of an `ActionController::Parameters` the attribute contains only the permitted keys)

`options` - an `ActiveSupport::HashWithIndifferentAccess` representation of the argument from the index, show, edit, update and destroy methods

`ransack` - the Ransack search object used when retrieving records in the index method (when using the Ransack search library)

## Adding Bespoke Methods

The manager classes provide standard implementations of the seven core CRUD methods. These can be overwritten to perform custom business logic and the classes can also be extended to include the business logic for additional actions, both making use of the internal ActiveManageable methods and variables.

```ruby
def complete(id:)
  initialize_state
  @target = model_class.find(id)
  authorize(record: @target, action: :complete?)
  @target.update(completed_by: current_user.id, completed_at: Time.zone.now)
end
```

Each method should first call the `initialize_state` method which has optional `attributes` and `options` keyword arguments. This method sets the `@target` variable to nil, sets the `@current_method` variable to the name of the method being executed as a symbol (eg. `:complete`) and sets the `@attributes` and `@options` variables after performing [attribute values parsing](#attribute-value-parsing).

The `model_class` method returns the `ActiveRecord` class set either automatically or manually when calling `manageable`.

The `@target` instance variable makes the model object or `ActiveRecord::Relation` (in the case of the index method) accessible to the internal ActiveManageable methods. For external access, there are less ambiguous alias methods named `object` and `collection`.

The `authorize` method performs authorization for the current user, record and action using the configuration library. The `record` argument can be a model class or instance and the `action` argument is optional with the default being the method name.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

You can also experiment in the rails console using the dummy app. Within the spec/dummy directory:

1. run `bin/rails db:setup` to create the database, load the schema, and initialize it with the seed data
2. run `rails c`

Then in the console:

```ruby
ActiveManageable.current_user = User.first
manager = AlbumManager.new
manager.index
```

After making changes:

1. run `rake spec` to run the tests and check the test coverage
2. run `open coverage/index.html` to view the test coverage report
3. run `bundle exec appraisal install` to install the appraisal dependencies or `bundle exec appraisal update` to upgrade the appraisal dependencies
4. run `bundle exec appraisal rspec` to run the tests against different versions of activerecord & activesupport
5. run `bundle exec rubocop` to check the style of files

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, commit the changes and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/CircleSD/active_manageable). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/CircleSD/active_manageable/blob/main/CODE_OF_CONDUCT.md).

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActiveManageable project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/CircleSD/active_manageable/blob/main/CODE_OF_CONDUCT.md).
