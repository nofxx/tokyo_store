require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Tokyo Session Store" do

  class TestController < ActionController::Base
    def no_session_access
      head :ok
    end

    def set_session_value
      session[:foo] = "bar"
      head :ok
    end

    def get_session_value
      render :text => "foo: #{session[:foo].inspect}"
    end

    def get_session_id
      session[:foo]
      render :text => "#{request.session_options[:id]}"
    end

    def call_reset_session
      session[:bar]
      reset_session
      session[:bar] = "baz"
      head :ok
    end

    def rescue_action(e) raise end
  end

  before(:each) do


    end

    it "test_setting_and_getting_session_value" do
      with_test_route_set do
        get '/set_session_value'
        response.should eql(:success)
        cookies['_session_id'].should be_true

        # get '/get_session_value'
        # assert_response :success
        # assert_equal 'foo: "bar"', response.body
      end
    end
  private
    def with_test_route_set
      with_routing do |set|
        set.draw do |map|
          map.with_options :controller => "mem_cache_store_test/test" do |c|
            c.connect "/:action"
          end
        end
        yield
      end
    end
    def with_routing
      real_routes = ActionController::Routing::Routes
      ActionController::Routing.module_eval { remove_const :Routes }

      temporary_routes = ActionController::Routing::RouteSet.new
      ActionController::Routing.module_eval { const_set :Routes, temporary_routes }

      yield temporary_routes
    ensure
      if ActionController::Routing.const_defined? :Routes
        ActionController::Routing.module_eval { remove_const :Routes }
      end
      ActionController::Routing.const_set(:Routes, real_routes) if real_routes
    end
end
