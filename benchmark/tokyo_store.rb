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

# # # Read & Write
Benchmark.bmbm do |b|
  b.report("Tokyo#write") { 100_000.times { |i| @tokyo.write i.to_s, "x" }}
  b.report("Tokyo#read") { 100_000.times { |i| @tokyo.read i.to_s }}
end

Benchmark.bmbm do |b|
  b.report("Memca#write") { 100_000.times { |i| @memca.write i.to_s, "x" }}
  b.report("Memca#read") { 100_000.times { |i| @memca.read i.to_s }}
end



# # Read & Write
# Benchmark.bmbm do |b|
#   b.report("Tokyo#write") { 100.times { |j| Thread.new { 10_000.times { |i| @tokyo.write "#{j}-#{i}", "x" }}}}
#   b.report("Tokyo#read") { 100.times { |j| Thread.new { 10_000.times { |i| @tokyo.read "#{j}-#{i}" }}}}
# end

# Benchmark.bmbm do |b|
#   b.report("Memca#write") { 100.times { |j| Thread.new { 10_000.times { |i| @memca.write "#{j}-#{i}", "x" }}}}
#   b.report("Memca#read") { 100.times { |j| Thread.new { 10_000.times { |i| @memca.read "#{j}-#{i}" }}}}
# end
