#
# Tokyo Store
#
# Benchmark vs MemCacheStore on memcached and tyrant
#
require 'rubygems'
require 'active_support'
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'tokyo_store'
#include TokyoCabinet

P = "x" * 100
M = P * 10
G = M * 10
OBJ = { :small => P, :medium => M, :big => G}

@tokyo = ActiveSupport::Cache.lookup_store :tokyo_store, "localhost"
@memca = ActiveSupport::Cache.lookup_store :mem_cache_store, "localhost:11211"
@memto = ActiveSupport::Cache.lookup_store :mem_cache_store, "localhost:45001"

# # Read & Write
Benchmark.bmbm do |b|
  b.report("TokyoStore#P") { 10_000.times { |i| @tokyo.write i.to_s, P }}
  b.report("MemCacheD#P") { 10_000.times { |i| @memca.write i.to_s, P }}
  b.report("MemCacheT#P") { 10_000.times { |i| @memto.write i.to_s, P }}

  b.report("TokyoStore#M") { 10_000.times { |i| @tokyo.write i.to_s, M }}
  b.report("MemCacheD#M") { 10_000.times { |i| @memca.write i.to_s, M }}
  b.report("MemCacheT#M") { 10_000.times { |i| @memto.write i.to_s, M }}

  b.report("TokyoStore#G") { 10_000.times { |i| @tokyo.write i.to_s, G }}
  b.report("MemCacheD#G") { 10_000.times { |i| @memca.write i.to_s, G }}
  b.report("MemCacheT#G") { 10_000.times { |i| @memto.write i.to_s, G }}

  b.report("TokyoStore#OB") { 10_000.times { |i| @tokyo.write i.to_s, OBJ }}
  b.report("MemCacheD#OB") { 10_000.times { |i| @memca.write i.to_s, OBJ }}
  b.report("MemCacheT#OB") { 10_000.times { |i| @memto.write i.to_s, OBJ }}

  b.report("TokyoStore#R") { 10_000.times { |i| @tokyo.read i.to_s }}
  b.report("MemCacheD#R") { 10_000.times { |i| @memca.read i.to_s }}
  b.report("MemCacheT#R") { 10_000.times { |i| @memto.read i.to_s }}

end


puts
# # Read & Write
Benchmark.bmbm do |b|
  b.report("MemCa#w") { 100.times { |j| Thread.new { 100.times { |i| @memca.write "#{j}-#{i}", OBJ }}}}
  b.report("Memca#r") { 100.times { |j| Thread.new { 100.times { |i| @memca.read "#{j}-#{i}" }}}}
  b.report("Memto#w") { 100.times { |j| Thread.new { 100.times { |i| @memto.write "#{j}-#{i}", OBJ }}}}
  b.report("Memto#r") { 100.times { |j| Thread.new { 100.times { |i| @memto.read "#{j}-#{i}" }}}}
  b.report("Tokyo#w") { 100.times { |j| Thread.new { 100.times { |i| @tokyo.write "#{j}-#{i}", OBJ }}}}
  b.report("Tokyo#r") { 100.times { |j| Thread.new { 100.times { |i| @tokyo.read "#{j}-#{i}" }}}}
end
