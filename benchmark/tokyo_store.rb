#
#
require 'rubygems'
require 'active_support'
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'tokyo_store'
#include TokyoCabinet

@tokyo = ActiveSupport::Cache.lookup_store :tokyo_store, "localhost"
@memca = ActiveSupport::Cache.lookup_store :mem_cache_store, "localhost:11211"
@memto = ActiveSupport::Cache.lookup_store :mem_cache_store, "localhost:45001"

# # # Read & Write
Benchmark.bmbm do |b|
  b.report("TokyoStore#w") { 10_000.times { |i| @tokyo.write i.to_s, "x" }}
  b.report("TokyoStore#r") { 10_000.times { |i| @tokyo.read i.to_s }}
  b.report("MemCache#w") { 10_000.times { |i| @memca.write i.to_s, "x" }}
  b.report("MemCache#r") { 10_000.times { |i| @memca.read i.to_s }}
  b.report("MemCacheTo#w") { 10_000.times { |i| @memto.write i.to_s, "x" }}
  b.report("MemCacheTo#r") { 10_000.times { |i| @memto.read i.to_s }}
end


puts
# # Read & Write
Benchmark.bmbm do |b|
  b.report("Tokyo#w") { 100.times { |j| Thread.new { 100.times { |i| @tokyo.write "#{j}-#{i}", "x" }}}}
  b.report("Tokyo#r") { 100.times { |j| Thread.new { 100.times { |i| @tokyo.read "#{j}-#{i}" }}}}
  b.report("MemCa#w") { 100.times { |j| Thread.new { 100.times { |i| @memca.write "#{j}-#{i}", "x" }}}}
  b.report("Memca#r") { 100.times { |j| Thread.new { 100.times { |i| @memca.read "#{j}-#{i}" }}}}
  b.report("Memto#w") { 100.times { |j| Thread.new { 100.times { |i| @memto.write "#{j}-#{i}", "x" }}}}
  b.report("Memto#r") { 100.times { |j| Thread.new { 100.times { |i| @memto.read "#{j}-#{i}" }}}}
end
