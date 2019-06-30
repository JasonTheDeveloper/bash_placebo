require 'simplecov-cobertura'

SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter

SimpleCov.add_filter 'test/'
SimpleCov.add_filter 'shunit2'