#
# Tokyo Store
#
# Benchmark vs MemCacheStore on memcached and tyrant
#
$: << File.join(File.dirname(__FILE__), "/../lib")
require 'rubygems'
require 'active_support'
require 'cache/tokyo_store'
require 'redis-store'
require 'cache/rails/redis_store'

P = "x" * 100
M = P * 10
G = M * 10
A = [P, M, G]
X = { :small => P, :medium => M, :big => G }
class User; attr_accessor :name, :info; end
u = User.new; u.name = P; u.info = G
O = u
T = ARGV[0].to_i || 10000

#TODO: Cabinet & memcached C bindings
TEST = {
 "TokyoStore" => ActiveSupport::Cache.lookup_store(:tokyo_store, "localhost:1978"),
 "MemTokyo"   => ActiveSupport::Cache.lookup_store(:mem_cache_store, "localhost:1978"),
 "RedisStore" => ActiveSupport::Cache.lookup_store(:redis_store, "localhost:6379"),
 "MemCache"   => ActiveSupport::Cache.lookup_store(:mem_cache_store, "localhost:11211"),
}

puts " Write"
puts "----------"
Benchmark.bmbm do |b|
  TEST.each_pair do |k,s|
    b.report("#{k} P") { T.times { |i| s.write i.to_s, P }}
    b.report("#{k} M") { T.times { |i| s.write i.to_s, M }}
    b.report("#{k} G") { T.times { |i| s.write i.to_s, G }}
    b.report("#{k} Obj") { T.times { |i| s.write i.to_s, O }}
    b.report("#{k} Hash") { T.times { |i| s.write i.to_s, X }}
    b.report("#{k} Array") { T.times { |i| s.write i.to_s, A }}
    b.report("#{k} Delete") { T.times { |i| s.delete i.to_s }}
    b.report("#{k} +") { T.times { |i| s.increment i.to_s }}
    b.report("#{k} -") { T.times { |i| s.decrement i.to_s }}
  end
end

puts " Read"
puts "----------"
TEST.each { |p| 10_000.times { |i| p[1].write i.to_s, G }}
#TODO: implement read with diff data.
Benchmark.bmbm do |b|
  TEST.each_pair do |k,s|
    k = s.class.to_s.split("::")[-1]
    b.report("#{k} Seq") { T.times { |i| s.read rand(i).to_s }}
    b.report("#{k} Rand") { T.times { |i| s.read rand(i).to_s }}
    b.report("#{k} Exist") { T.times { |i| s.exist? i.to_s }}
  end
end

puts
thr = []
Benchmark.bmbm do |b|
  TEST.each_pair do |k,s|
    b.report("#{k} TW") { (T/2).times { |j| thr << Thread.new { (T/2).times { |i| s.write "#{j}-#{i}", X }}};  thr.each { |t| t.join }; thr = [] }
    b.report("#{k} TR") { (T/2).times { |j| thr << Thread.new { (T/2).times { |i| s.read "#{j}-#{i}" }}};  thr.each { |t| t.join }; thr = [] }
  end
end

__END__

*NOTE: Redis and Memcache support native expiration, Tokyo doesn't.
Wondering the impact of this feature written in ruby...

Core 2 Duo 8500 - 3.16Ghz
------------------------------------------------------------
 Write
-------------
TokyoStore# P    0.140000   0.090000   0.230000 (  0.367587)
RedisStore# P    0.340000   0.090000   0.430000 (  0.542441)
MemCacheD # P    0.570000   0.160000   0.730000 (  0.829167)
MemCacheT # P    0.560000   0.170000   0.730000 (  0.897084)

TokyoStore# M    0.170000   0.100000   0.270000 (  0.448071)
RedisStore# M    0.360000   0.120000   0.480000 (  0.641083)
MemCacheD # M    0.610000   0.140000   0.750000 (  0.878559)
MemCacheT # M    0.630000   0.140000   0.770000 (  0.951748)

TokyoStore# G    0.410000   0.090000   0.500000 (  0.976746)
RedisStore# G    0.930000   0.170000   1.100000 (  1.572024)
MemCacheD # G    1.000000   0.200000   1.200000 (  1.429635)
MemCacheT # G    1.060000   0.170000   1.230000 (  1.558731)

TokyoStore# D    0.220000   0.170000   0.390000 (  0.707877)
RedisStore# D    0.240000   0.110000   0.350000 (  0.474265)
MemCacheD # D    0.560000   0.110000   0.670000 (  0.775865)
MemCacheT # D    0.560000   0.140000   0.700000 (  0.860964)

TokyoStore# +    0.230000   0.190000   0.420000 (  0.654690)
RedisStore# +    0.200000   0.120000   0.320000 (  0.494333)
MemCacheD # +    0.570000   0.130000   0.700000 (  0.801407)
MemCacheT # +    0.540000   0.190000   0.730000 (  0.937882)

TokyoStore# -    0.200000   0.210000   0.410000 (  0.669899)
RedisStore# -    0.240000   0.120000   0.360000 (  0.511279)
MemCacheD # -    0.600000   0.100000   0.700000 (  0.778212)
MemCacheT # -    0.600000   0.140000   0.740000 (  0.983345)

 Read
--------------
TokyoStore# Seq     0.440000   0.150000   0.590000 (  0.858501)
RedisStore# Seq     0.660000   0.130000   0.790000 (  1.039310)
MemCacheD # Seq     0.830000   0.220000   1.050000 (  1.135630)
MemCacheT # Seq     1.210000   0.190000   1.400000 (  1.754004)

TokyoStore# Rand    0.490000   0.200000   0.690000 (  1.003466)
RedisStore# Rand    0.580000   0.210000   0.790000 (  1.877162)
MemCacheD # Rand    0.870000   0.170000   1.040000 (  1.135382)
MemCacheT # Rand    1.410000   0.230000   1.640000 (  1.971372)

TokyoStore# Exist   0.460000   0.140000   0.600000 (  0.845920)
RedisStore# Exist   0.550000   0.250000   0.800000 (  1.658580)
MemCacheD # Exist   0.810000   0.220000   1.030000 (  1.138310)
MemCacheT # Exist   1.150000   0.250000   1.400000 (  1.760770)


Tokyo # W   0.510000   0.150000   0.660000 (  1.023739)
Redis # W   0.540000   0.140000   0.680000 (  1.032881)
MemCa # W   2.530000   0.210000   2.740000 (  3.072881)
MemTo # W   2.600000   0.280000   2.880000 (  3.344125)

Tokyo # R   0.680000   0.210000   0.890000 (  2.547828)
Redis # R   0.710000   0.220000   0.930000 (  2.599269)
MemCa # R   2.190000   0.240000   2.430000 (  2.977408)
MemTo # R   3.210000   0.330000   3.540000 (  4.298882)
