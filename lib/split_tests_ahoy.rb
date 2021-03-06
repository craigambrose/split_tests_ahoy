require "split_tests_ahoy/engine"
require 'split_tests_ahoy/algorithms/weighted_sample'
require 'split_tests_ahoy/alternative'
require 'split_tests_ahoy/controller_extensions'

begin
  RailsAdmin
  require 'split_tests_ahoy/rails_admin'
rescue NameError
  nil
end

require 'split_tests_ahoy/participation_scopes'

module SplitTestsAhoy
  mattr_accessor :alternative_selector
  mattr_accessor :experiments
end

SplitTestsAhoy.alternative_selector = SplitTestsAhoy::Algorithms::WeightedSample.new
