#
# Tokyo Store
#
# Session Benchmark vs MemCacheStore on memcached and tyrant
#
$: << File.join(File.dirname(__FILE__), "/../lib")
require 'rubygems'
require 'benchmark'
require 'rack'
require 'tokyo_store'
require 'redis-store'
#S = [Rack::Session::Tokyo::DEFAULT_OPTIONS[:key], { :test => "foo"}]
T = ARGV[0].to_i || 10000

rack = lambda do |env|
  env["rack.session"]["counter"] ||= 0
  env["rack.session"]["counter"] += 1
  Rack::Response.new(env["rack.session"].inspect).to_a
end

TEST = {
  "Tokyo" =>  Rack::Session::Tokyo.new(rack),
  "Redis" => Rack::Session::Redis.new(rack),
}
bar = "_" * 45

puts "\n#{bar}  GET"
Benchmark.bmbm do |b|
  TEST.each_pair do |n,s|
    b.report(n) do T.times do
      req = Rack::MockRequest.new(s)
      cookie = req.get("/")["Set-Cookie"]
      req.get("/", "HTTP_COOKIE" => cookie)
    end end
  end
end

puts "\n#{bar}  SET"
Benchmark.bmbm do |b|
  TEST.each_pair do |n,s|
    b.report(n) {  T.times {  Rack::MockRequest.new(s).get("/") }}
  end
end

puts "\n#{bar} EXIST"
Benchmark.bmbm do |b|
  TEST.each_pair do |n,s|
    b.report(n) do T.times do
      Rack::MockRequest.new(s).get("/", "HTTP_COOKIE" => "rack.session=badbadcookie")
    end end
  end
end


__END__

_____________________________________________  GET
Tokyo   6.310000   1.030000   7.340000 (  8.511138)
Redis   7.300000   1.010000   8.310000 (  9.325441)
------------------------------- total: 15.650000sec

_____________________________________________  SET
Tokyo   3.340000   0.540000   3.880000 (  4.562920)
Redis   3.960000   0.540000   4.500000 (  5.030627)
-------------------------------- total: 8.380000sec

_____________________________________________ EXIST
Redis   4.700000   0.700000   5.400000 (  6.061131)
Tokyo   4.090000   0.650000   4.740000 (  5.537898)
------------------------------- total: 10.140000sec
