require 'split_tests_ahoy/alternative'

module SplitTestsAhoy
  class Experiment < ActiveRecord::Base
    has_many :participants, dependent: :delete_all

    def self.ensure_started(name)
      find_or_create_by(name: name)
    end

    def existing_alternative_for(visit)
      participant = participants.for_visit(visit).last
      participant.alternative_name if participant
    end

    def start_visit_participation(visit, alternative)
      participants.for_visit(visit).create!(alternative_name: alternative)
    end

    def load_configuration(alternative_names = nil)
      config_details = if global_config
        unless alternative_names.nil? || alternative_names.empty?
          raise ArgumentError, "Don't provide alternative names via the method call if you also provide configure this experiment in your initializer"
        end
        global_config
      elsif alternative_names
        {alternatives: alternative_names}
      else
        {alternatives: alternative_names_from_participants}
      end

      load_configuration_hash config_details
    end

    def alternatives
      raise RuntimeError, "You must call load_configuration before accessing alternatives" if @alternatives.nil?
      @alternatives
    end

    def metric_class
      raise ArgumentError.new("no metric") unless @metric
      @metric
    end

    private

    def global_config
      raise ArgumentError if name.blank?
      (SplitTestsAhoy.experiments || {})[name]
    end

    def load_configuration_hash(config)
      @alternatives = config[:alternatives].map do |config|
        Alternative.load_from_config(self, config)
      end
      @metric = config[:metric].constantize if config[:metric]
      check_configuration
    end

    def check_configuration
      percentages = @alternatives.map(&:percent)
      if (percentages.compact.present?)
        raise ArgumentError, "if you specify a percentage for one option, you must do so for all" if percentages.detect(&:nil?)
        raise ArgumentError, "if you specify percentages, they must add to 100" if percentages.sum != 100
      end
    end

    def alternative_names_from_participants
      column = "alternative_name"
      participants.group(column).pluck(column)
    end
  end
end