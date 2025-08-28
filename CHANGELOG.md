# Change Log

## 0.3.0 - 2025-08-28

* Add support and test coverage for all minor versions of Rails 7 and Ruby 3
* Drop support for Rails 6 and Ruby 2.7
* Use base_label in calling_method method for Ruby 3.4.x compatibility

## 0.2.0 - 2022-09-27

* Allow the configuration library options to accept a module
* Add `action_scope` method that can be overridden in order to retrieve and maintain records using a scope
* Rename `scoped_class` method to `authorization_scope`
* Move instance method definitions out of the ActiveSupport::Concern included block so that they can be overridden
* Split action methods into smaller overridable methods
* Add a yield to each of the action methods
* Perform yield and object create, update & destroy within a transaction
* Add public instance methods to return the default options
* When using the Kaminari library provide the ability to use the `without_count` mode to create a paginatable collection without counting the total number of records; either via the index method options or a class option or configuration option

## 0.1.2 - 2022-08-25

* Upgrade gems including activerecord, actionpack, actionview, nokogiri & rack to resolve security advisory alerts

## 0.1.1 - 2022-04-18

* Upgrade nokogiri to v1.13.4 to resolve security advisory

## 0.1.0 - 2022-03-21

* Initial release
