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
X = { :small => P, :medium => M, :big => G}

#TODO: Cabinet & memcached C bindings
@tokyo = ActiveSupport::Cache.lookup_store :tokyo_store, "localhost:1978"
@memca = ActiveSupport::Cache.lookup_store :mem_cache_store, "localhost:11211"
@memto = ActiveSupport::Cache.lookup_store :mem_cache_store, "localhost:1978"
@redis = ActiveSupport::Cache.lookup_store :redis_store, "localhost:6379"

puts " Write"
puts "--------------"
Benchmark.bmbm do |b|
  b.report("TokyoStore# P") { 10_000.times { |i| @tokyo.write i.to_s, P }}
  b.report("RedisStore# P") { 10_000.times { |i| @redis.write i.to_s, P }}
  b.report("MemCacheD # P") { 10_000.times { |i| @memca.write i.to_s, P }}
  b.report("MemCacheT # P") { 10_000.times { |i| @memto.write i.to_s, P }}
  b.report("TokyoStore# M") { 10_000.times { |i| @tokyo.write i.to_s, M }}
  b.report("RedisStore# M") { 10_000.times { |i| @redis.write i.to_s, M }}
  b.report("MemCacheD # M") { 10_000.times { |i| @memca.write i.to_s, M }}
  b.report("MemCacheT # M") { 10_000.times { |i| @memto.write i.to_s, M }}
  b.report("TokyoStore# G") { 10_000.times { |i| @tokyo.write i.to_s, G }}
  b.report("RedisStore# G") { 10_000.times { |i| @redis.write i.to_s, G }}
  b.report("MemCacheD # G") { 10_000.times { |i| @memca.write i.to_s, G }}
  b.report("MemCacheT # G") { 10_000.times { |i| @memto.write i.to_s, G }}
  b.report("TokyoStore# D") { 10_000.times { |i| @tokyo.delete i.to_s }}
  b.report("RedisStore# D") { 10_000.times { |i| @redis.delete i.to_s }}
  b.report("MemCacheD # D") { 10_000.times { |i| @memca.delete i.to_s }}
  b.report("MemCacheT # D") { 10_000.times { |i| @memto.delete i.to_s }}
  b.report("TokyoStore# +") { 10_000.times { |i| @tokyo.increment i.to_s }}
  b.report("RedisStore# +") { 10_000.times { |i| @redis.increment i.to_s }}
  b.report("MemCacheD # +") { 10_000.times { |i| @memca.increment i.to_s }}
  b.report("MemCacheT # +") { 10_000.times { |i| @memto.increment i.to_s }}
  b.report("TokyoStore# -") { 10_000.times { |i| @tokyo.decrement i.to_s }}
  b.report("RedisStore# -") { 10_000.times { |i| @redis.decrement i.to_s }}
  b.report("MemCacheD # -") { 10_000.times { |i| @memca.decrement i.to_s }}
  b.report("MemCacheT # -") { 10_000.times { |i| @memto.decrement i.to_s }}
end

puts " Read"
10_000.times { |i| @tokyo.write i.to_s, G }
10_000.times { |i| @redis.write i.to_s, G }
10_000.times { |i| @memca.write i.to_s, G }
10_000.times { |i| @memto.write i.to_s, G }
puts "--------------"
#TODO: implement read with diff data.
Benchmark.bmbm do |b|
  b.report("TokyoStore# Seq") { 10_000.times { |i| @tokyo.read i.to_s }}
  b.report("RedisStore# Seq") { 10_000.times { |i| @redis.read i.to_s }}
  b.report("MemCacheD # Seq") { 10_000.times { |i| @memca.read i.to_s }}
  b.report("MemCacheT # Seq") { 10_000.times { |i| @memto.read i.to_s }}
  b.report("TokyoStore# Rand") { 10_000.times { |i| @tokyo.read rand(i).to_s }}
  b.report("RedisStore# Rand") { 10_000.times { |i| @tokyo.read rand(i).to_s }}
  b.report("MemCacheD # Rand") { 10_000.times { |i| @memca.read rand(i).to_s }}
  b.report("MemCacheT # Rand") { 10_000.times { |i| @memto.read rand(i).to_s }}
  b.report("TokyoStore# Exist") { 10_000.times { |i| @tokyo.exist? i.to_s }}
  b.report("RedisStore# Exist") { 10_000.times { |i| @tokyo.exist? i.to_s }}
  b.report("MemCacheD # Exist") { 10_000.times { |i| @memca.exist? i.to_s }}
  b.report("MemCacheT # Exist") { 10_000.times { |i| @memto.exist? i.to_s }}
end

puts
thr = []
Benchmark.bmbm do |b|
  b.report("Tokyo # W") {  100.times { |j| thr << Thread.new { 100.times { |i| @tokyo.write "#{j}-#{i}", X }}};  thr.each { |t| t.join }; thr = [] }
  b.report("Redis # W") {  100.times { |j| thr << Thread.new { 100.times { |i| @tokyo.write "#{j}-#{i}", X }}};  thr.each { |t| t.join }; thr = [] }
  b.report("MemCa # W") {  100.times { |j| thr << Thread.new { 100.times { |i| @memca.write "#{j}-#{i}", X}}};  thr.each { |t| t.join }; thr = [] }
  b.report("MemTo # W") {  100.times { |j| thr << Thread.new { 100.times { |i| @memto.write "#{j}-#{i}", X}}};  thr.each { |t| t.join }; thr = [] }
  b.report("Tokyo # R") {  100.times { |j| thr << Thread.new { 100.times { |i| @tokyo.read "#{j}-#{i}" }}};  thr.each { |t| t.join }; thr = [] }
  b.report("Redis # R") {  100.times { |j| thr << Thread.new { 100.times { |i| @tokyo.read "#{j}-#{i}" }}};  thr.each { |t| t.join }; thr = [] }
  b.report("MemCa # R") {  100.times { |j| thr << Thread.new { 100.times { |i| @memca.read "#{j}-#{i}"}}};  thr.each { |t| t.join }; thr = [] }
  b.report("MemTo # R") {  100.times { |j| thr << Thread.new { 100.times { |i| @memto.read "#{j}-#{i}"}}};  thr.each { |t| t.join }; thr = [] }
end

__END__



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
