# Checkit

This gem provides a small executable which can be run from every ruby project in order to help new developers to check if they are ready to run the project. It checks for various dependencies:

* Bundled gems
* Config files
* Servers installed and running

## Installation

Add this line to your application's Gemfile:

    gem 'checkit'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install checkit

## Usage

Change to your project directory and run ```checkit```, read the data and if something red is printed get some help ;)

## ToDo

* Check if foreman is installed and tell user to use it for running dependencies
* Check if a test suite is present and can be run
* Cleanup the existing code
* Create a central service repository whcih resolves all dependencies
* Check environments

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
