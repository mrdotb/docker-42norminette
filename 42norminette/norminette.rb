#!/usr/bin/env /usr/bin/rbx

# Ce code est sacrément degueulasse :)
# OUI.
# Bah proprifie le alors!!

require 'bundler'
current_path = Dir.pwd

# No.
# Dir.chdir File.expand_path(File.dirname(__FILE__))

# is file a symlink ? Yes -> get real path (follow the symlink correctly) No -> get path

if File.symlink?(__FILE__)
    dir = File.expand_path(File.dirname(File.readlink(__FILE__)))
    Dir.chdir dir
else
	dir = File.expand_path(File.dirname(__FILE__))
	Dir.chdir dir
end

Bundler.require

require 'active_support/core_ext/string'

Dir.chdir current_path

if Dir.exists? "#{dir}/compiled"
	Rubinius::CodeLoader.require_compiled "#{dir}/compiled/engine/debug"
	Rubinius::CodeLoader.require_compiled "#{dir}/compiled/engine/version"
	Rubinius::CodeLoader.require_compiled "#{dir}/compiled/rules"
	Rubinius::CodeLoader.require_compiled "#{dir}/compiled/engine/my_parser"
	Rubinius::CodeLoader.require_compiled "#{dir}/compiled/engine/parser"
	Rubinius::CodeLoader.require_compiled "#{dir}/compiled/engine/checker"
	Rubinius::CodeLoader.require_compiled "#{dir}/compiled/engine/source"
	Rubinius::CodeLoader.require_compiled "#{dir}/compiled/engine/error"
	Rubinius::CodeLoader.require_compiled "#{dir}/compiled/engine/pos"
	Rubinius::CodeLoader.require_compiled "#{dir}/compiled/engine/cache"
	Rubinius::CodeLoader.require_compiled "#{dir}/compiled/engine/rediscache"
	Rubinius::CodeLoader.require_compiled "#{dir}/compiled/engine/sqlitecache"
	Rubinius::CodeLoader.require_compiled "#{dir}/compiled/engine/stats"
# Nothing to do here
# Dir.chdir File.expand_path(File.dirname(__FILE__))
	Dir["#{dir}/compiled/rules/*.rbc"].each {|filename| Rubinius::CodeLoader.require_compiled filename}
# Nothing to do here
#  	Dir.chdir current_path
	Rubinius::CodeLoader.require_compiled "#{dir}/compiled/engine/run"

	debug "Mode compile"
else
	require_relative 'src/engine/debug'
	require_relative 'src/engine/version'
	require_relative 'src/rules'
	require_relative 'src/engine/my_parser'
	require_relative 'src/engine/parser'
	require_relative 'src/engine/checker'
	require_relative 'src/engine/source'
	require_relative 'src/engine/error'
	require_relative 'src/engine/pos'
	require_relative 'src/engine/cache'
	require_relative 'src/engine/rediscache'
	require_relative 'src/engine/sqlitecache'
	require_relative 'src/engine/stats'
	Dir['./src/rules/*.rb'].each {|filename| require_relative filename}
	require_relative 'src/engine/run'

	debug "Mode non compile"
end

Dir.chdir current_path
