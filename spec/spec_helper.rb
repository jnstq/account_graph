require 'rubygems'
require 'spec'
require 'sinatra'
require 'sinatra/test/rspec'

require File.dirname(__FILE__) + '/../account_graph.rb'

module AutoTagMatcher

  class AutoTag
    def initialize(description)
      @description = description
    end

    def matches?(transaction)
      @transaction = transaction
      @transaction.description = @description
      @transaction.set_auto_tag
      @transaction.tag.should == @tag
    end

    def to(tag)
      @tag = tag
      self
    end

    def failure_message
      "expected #{@transaction.inspect} to auto_tag #{@description.inspect}, but it didn't"
    end

    def negative_failure_message
      "expected #{@transaction.inspect} not to auto_tag #{@description.inspect}, but it did"
    end
  end

  def auto_tag(description)
    AutoTag.new(description)
  end

end

Spec::Runner.configure do |config|
  config.include AutoTagMatcher
  config.before do
    DB << "BEGIN"
  end
  config.after do
    DB << "ROLLBACK"
  end
end