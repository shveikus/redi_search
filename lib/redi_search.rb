# frozen_string_literal: true

require "redis"
require "active_support"

require "redi_search/configuration"

require "redi_search/railtie"
require "redi_search/model"
require "redi_search/index"
require "redi_search/log_subscriber"

module RediSearch
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def reset
      @configuration = Configuration.new
    end

    def configure
      yield(configuration)
    end

    def client
      configuration.client
    end
  end
end

ActiveSupport.on_load(:active_record) do
  extend RediSearch::Model
end
RediSearch::LogSubscriber.attach_to :redi_search