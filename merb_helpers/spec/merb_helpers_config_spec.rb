require File.dirname(__FILE__) + '/spec_helper'
FIXTURES_DIR = File.dirname(__FILE__) + '/fixtures'
MERB_HELPERS_ROOT = File.dirname(__FILE__) + "/.."

require 'merb_helpers'

describe "loading configuration" do
  
  before :each do
    unload_merb_helpers
  end
  
  after :all do
    reload_merb_helpers
  end
  
  it "should not have any helper available now" do
    unload_merb_helpers
    defined?(Merb::Helpers).should be_nil    
  end
  
  it "should load reload_merb_helpers" do
    unload_merb_helpers
    reload_merb_helpers
    defined?(Merb::Helpers).should_not be_nil    
  end
  
  it "should load all helpers by default" do
    reload_merb_helpers
    defined?(Merb::Helpers).should_not be_nil
    defined?(Merb::Helpers::Form).should_not be_nil
  end
  
  it "should load all helpers by default" do
    Merb::Plugins.should_receive(:config).and_return({})
    reload_merb_helpers
    defined?(Merb::Helpers).should_not be_nil
    defined?(Merb::Helpers::DateAndTime).should_not  be_nil
    defined?(Merb::Helpers::Form)
  end
  
  it "should raise an error if :with or :without are configured" do
    Merb::Plugins.stub!(:config).and_return(:merb_helpers => {:with => "form_helpers", :without => "date_format_helpers"})
    lambda do 
      reload_merb_helpers
    end.should raise_error
    
    Merb::Plugins.stub!(:config).and_return(:merb_helpers => {:with => "form_helpers"})
    lambda do 
      reload_merb_helpers
    end.should raise_error
    
    Merb::Plugins.stub!(:config).and_return(:merb_helpers => {:without => "date_format_helpers"})
    lambda do 
      reload_merb_helpers
    end.should raise_error
  end
  
  it "should only load the helpers specified in the config hash (if defined)" do
    unload_merb_helpers
    defined?(Merb::Helpers).should be_nil
    defined?(Merb::Helpers::DateAndTime).should be_nil
    Merb::Plugins.stub!(:config).and_return(:merb_helpers => {:include => "form_helpers"})
    reload_merb_helpers
    defined?(Merb::Helpers).should_not be_nil
    defined?(Merb::Helpers::Form).should_not be_nil
    defined?(Merb::Helpers::DateAndTime).should be_nil
    
    unload_merb_helpers
    defined?(Merb::Helpers).should be_nil
    defined?(Merb::Helpers::DateAndTime).should be_nil
    Merb::Plugins.stub!(:config).and_return(:merb_helpers => {:include => ["form_helpers", "date_time_helpers"]})
    reload_merb_helpers
    defined?(Merb::Helpers).should_not be_nil
    defined?(Merb::Helpers::Form).should_not be_nil
    defined?(Merb::Helpers::DateAndTime).should_not be_nil
  end
  
  it "should load all helpers if the include hash is empty" do
    unload_merb_helpers
    defined?(Merb::Helpers).should be_nil
    defined?(Merb::Helpers::DateAndTime).should be_nil
    Merb::Plugins.stub!(:config).and_return(:merb_helpers => {:include => ""})
    reload_merb_helpers
    defined?(Merb::Helpers).should_not be_nil
    defined?(Merb::Helpers::Form).should_not be_nil
    defined?(Merb::Helpers::DateAndTime).should_not be_nil
  end
  
  it "should load helpers if the plugin conf is defined but the include pair is missing" do
    unload_merb_helpers
    defined?(Merb::Helpers).should be_nil
    defined?(Merb::Helpers::DateAndTime).should be_nil
    Merb::Plugins.stub!(:config).and_return(:merb_helpers => {})
    reload_merb_helpers
    defined?(Merb::Helpers).should_not be_nil
    defined?(Merb::Helpers::Form).should_not be_nil
    defined?(Merb::Helpers::DateAndTime).should_not be_nil
  end
  
end