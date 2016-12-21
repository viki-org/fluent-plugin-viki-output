require 'spec_helper'
require 'fluent/plugin/geoip'

RSpec.describe Fluent::VikiOutput do

  before(:all) { 
    Fluent::Test.setup 
    Fluent::Geoip.set_geoip_db_path('spec/cache/GeoLite2-City.mmdb')

  }

  let(:now) { Time.parse("2011-01-02 13:14:15 UTC") }
  let(:now_ts) { now.to_i }

  let(:driver) { Fluent::Test::OutputTestDriver.new(described_class) }

  let(:default_emit) {
    {"country"=>nil,"ip"=>nil, "ip_raw"=>nil,
    "mid"=>"fix_mid","path"=>nil, "t"=>now_ts.to_s}
  }

  let(:default_params) {
    {"mid"=>"fix_mid"}
  }

  let(:default_input) {
    {'headers'=>{}}
  }

  describe 'out_viki_output' do
    describe 'filter by status and set to correct tag based on path' do
  	  it 'filter out all non-200 requests' do
  		  Timecop.freeze(now) do
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test1'})
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test2'})
  			  driver.run do
  				  driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test1'})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 400,'params' => default_params.merge({'event'=>'test'})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 401,'params' => default_params.merge({'event'=>'test'})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 500,'params' => default_params.merge({'event'=>'test'})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test2'})}.to_json}))
  			  end
  		  end
  	  end

  	  it 'tags are extracted from path' do
  		  Timecop.freeze(now) do
          driver.expect_emit 'production', now_ts, default_emit.merge({'event' =>'test1','path' => '/api/production'})
          driver.expect_emit 'development', now_ts, default_emit.merge({'event' =>'test2','path' => '/api/development'})
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test3','path' => 'something'})
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test4','path' => ''})
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test5','path' => nil})
  			  driver.run do
            driver.emit(default_input.merge({'messages' => {'status' => 200,'path' => '/api/production','params' => default_params.merge({'event'=>'test1'})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 200,'path' => '/api/development','params' => default_params.merge({'event'=>'test2'})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 200,'path' => 'something','params' => default_params.merge({'event'=>'test3'})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 200,'path' => '','params' => default_params.merge({'event'=>'test4'})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test5'})}.to_json}))
  			  end
  			  
  		  end
      end
  	end

    describe 'fixing fields in params' do

      it 'rename country_code to country (if country_code is present)' do
        Timecop.freeze(now) do
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test1','country' => 'us'})
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test2','country' => ''})
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test3','country' => 'mx'})
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test4','country' => 'us'})
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test5','country' => ''})
          driver.run do
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test1','country_code' => 'us'})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test2','country_code' => ''})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test3','country' => 'mx'})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test4','country' => 'mx','country_code' => 'us'})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test5','country' => 'mx','country_code' => ''})}.to_json}))
          end
          
        end
      end

      it 'rename viki_uuid to uuid (if viki_uuid is present)' do
        Timecop.freeze(now) do
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test1','uuid' => '1234'})
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test2','uuid' => ''})
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test3','uuid' => '1234'})
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test4','uuid' => '1234'})
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test5','uuid' => ''})
          driver.run do
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test1','viki_uuid' => '1234'})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test2','viki_uuid' => ''})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test3','uuid' => '1234'})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test4','uuid' => '5678','viki_uuid' => '1234'})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test5','uuid' => '5678','viki_uuid' => ''})}.to_json}))
          end
        end
      end

      it 'rename type to content_provider (if type is present)' do
        Timecop.freeze(now) do
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test1','content_provider' => '1234'})
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test2','content_provider' => ''})
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test3','content_provider' => '1234'})
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test4','content_provider' => '1234'})
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test5','content_provider' => ''})
          driver.run do
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test1','type' => '1234'})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test2','type' => ''})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test3','content_provider' => '1234'})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test4','content_provider' => '5678','type' => '1234'})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test5','content_provider' => '5678','type' => ''})}.to_json}))
          end
        end
      end

      it 'rename dev_model to device_id (if dev_model is present)' do
        Timecop.freeze(now) do
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test1','device_id' => '1234'})
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test2','device_id' => ''})
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test3','device_id' => '1234'})
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test4','device_id' => '1234'})
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test5','device_id' => ''})
          driver.run do
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test1','dev_model' => '1234'})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test2','dev_model' => ''})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test3','device_id' => '1234'})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test4','device_id' => '5678','dev_model' => '1234'})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test5','device_id' => '5678','dev_model' => ''})}.to_json}))
          end
        end
      end

      it "change all 'null' strings to ''" do
        Timecop.freeze(now) do
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test1','field1' => ''})
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test2','field1' => '','field2'=>''})
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test3','field1' => '','field2'=>''})
          driver.run do
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test1','field1' => 'null'})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test2','field1' => 'null','field2'=>'null'})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test3','field1' => '','field2'=>'null'})}.to_json}))
          end
        end
      end
    end

    describe 'timestamp' do
      it 'get timestamp from params' do 
        Timecop.freeze(now) do
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test1','t' => '123456789'})
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test2','t' => '123456789'})
          driver.run do
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test1','t'=>123456789})}.to_json}))
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test2','t'=>'123456789'})}.to_json}))
          end
        end
      end

      it 'get timestamp from header' do 
        Timecop.freeze(now) do
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test1','t' => '200'})
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test2','t' => '200'})
          driver.run do
            driver.emit(default_input.merge({'headers' => {'TIMESTAMP' => '200'},'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test1'})}.to_json}))
            driver.emit(default_input.merge({'headers' => {'HTTP_TIMESTAMP' => '200'},'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test2'})}.to_json}))
          end
        end
      end

      it 'get timestamp from header even if t is in params' do 
        Timecop.freeze(now) do
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test1','t' => '200'})
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test2','t' => '200'})
          driver.run do
            driver.emit(default_input.merge({'headers' => {'TIMESTAMP' => '200'},'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test1','t'=>100})}.to_json}))
            driver.emit(default_input.merge({'headers' => {'HTTP_TIMESTAMP' => '200'},'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test2','t'=>'100'})}.to_json}))
          end
        end
      end

      it 'get timestamp from Fluentd event timestamp if both params and header do not contain the info' do 
        Timecop.freeze(now) do
          driver.expect_emit 'unknown', now_ts, default_emit.merge({'event' =>'test1','t' => now_ts.to_s})
          driver.run do
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test1'})}.to_json}))
          end
        end
      end

    end

    describe 'IP address' do

      let(:test_ip) {'202.73.39.34'}
      let(:expected_geoip_output) {
        {"city_name"=>"Singapore","country"=>"sg",
         "dma_code"=>nil,"latitude"=>"1.2854999999999999","longitude"=>"103.8565",
         "postal_code"=>nil,"region_name"=>"01"}
      }

      it 'extract country level and city level data from IP in params' do
        Timecop.freeze(now) do
          driver.expect_emit 'unknown', now_ts, default_emit.merge(expected_geoip_output.merge({"ip"=>test_ip,"ip_raw"=>test_ip,"event"=>"test1"}))
          driver.run do
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test1','ip'=>test_ip})}.to_json}))
          end
        end
      end

      it 'extract country level and city level data from IP in header if IP is not in params' do
        Timecop.freeze(now) do
          driver.expect_emit 'unknown', now_ts, default_emit.merge(expected_geoip_output.merge({"ip"=>test_ip,"ip_raw"=>test_ip,"event"=>"test1"}))
          driver.expect_emit 'unknown', now_ts, default_emit.merge(expected_geoip_output.merge({"ip"=>test_ip,"ip_raw"=>test_ip,"event"=>"test2"}))
          driver.run do
            driver.emit(default_input.merge({'headers'=>{'HTTP_X_FORWARDED_FOR'=>test_ip},'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test1'})}.to_json}))
            driver.emit(default_input.merge({'headers'=>{'REMOTE_ADDR'=>test_ip},'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test2'})}.to_json}))
          end
        end
      end

      it 'extract country level and city level data from ip present after the private ip' do
        Timecop.freeze(now) do
          driver.expect_emit 'unknown', now_ts, default_emit.merge(expected_geoip_output.merge({"ip"=>test_ip,"ip_raw"=>"10.0.0.0 10.0.1.1,#{test_ip}","event"=>"test1"}))
          driver.run do
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test1','ip'=>"10.0.0.0 10.0.1.1,#{test_ip}"})}.to_json}))
          end
        end
      end

      it 'country from IP address overwrite country/country_code in params' do 
        Timecop.freeze(now) do
          driver.expect_emit 'unknown', now_ts, default_emit.merge(expected_geoip_output.merge({"ip"=>test_ip,"ip_raw"=>test_ip,"event"=>"test1"}))
          driver.run do
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test1','ip'=>test_ip,'country_code'=>'us'})}.to_json}))
          end
        end
      end


    end

    describe "domain from site, also remove www" do
    [
      %w(https://www.google.com/test1/test2.html google.com),
      %w(http://www.viki.com/channels/2 viki.com),
      %w(www.viki.com viki.com),
      %w(www.google.com/test2/test3 google.com)
    ].each do |site, domain, length|
      it "convert #{site} to #{domain}" do
        Timecop.freeze(now) do
          driver.expect_emit 'unknown', now_ts, default_emit.merge({"domain"=>domain,"event"=>"test","site"=>site})
          driver.run do
            driver.emit(default_input.merge({'messages' => {'status' => 200,'params' => default_params.merge({'event'=>'test','site'=>site})}.to_json}))
          end
        end
      end
    end
    end


    # This test case need to be improved
    describe "mid" do
      it 'use HTTP_X_REQUEST_ID as mid if provided' do
        Timecop.freeze(now) do
          driver.expect_emit 'unknown', now_ts, default_emit.merge({"event"=>"test","mid"=>"test_value"})
          driver.run do
            driver.emit(default_input.merge({'headers' => {'HTTP_X_REQUEST_ID' =>"test_value"},'messages' => {'status' => 200,'params' => default_params.merge({'mid'=>nil, 'event'=>'test'})}.to_json}))
          end
        end
      end
    end

  end
end


