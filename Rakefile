# Not enough time right now to do this

MODULES = %w(memetic spidermonkey icu erlang pcre lighttpd couchdb)

desc "Build all of the modules"
task :build do
  # TODO: read some docs to find a better way to do this
  # when I have some time.
  MODULES.each do |m|
		Dir.chdir("modules/#{m}")
    begin
      sh "rake"
    ensure
      Dir.chdir('../..')
    end
	end
end

desc "Unpack all gems"
task :unpack_modules do
  Dir.chdir("#{Dir.pwd}/GEM_SERVER/gems") do
    FileUtils.rm_rf('modules')
    FileUtils.mkdir('modules')
    Dir["*.gem"].each do |gem|
      sh "gem unpack #{gem} --quiet --no-verbose"
      dirname = File.basename(gem, '.gem')
      gem_name = MODULES.find { |m| gem.match(/^memetic-#{m}/) }
      canonical_name = gem_name ? ("memetic-#{gem_name}") : gem.gsub(/-([\d\.]+)\.gem$/, '')
      FileUtils.mv(dirname, "modules/#{canonical_name}")
    end
  end
end

desc "Remove the test-db"
task :remove_test_db  do
  sh 'rm -rf test-db'
end

desc "Start CouchDB using gems"
task :start_couchdb  do
  require "rubygems"
	require "memetic-couchdb"
  db = Memetic::CouchDB.new("#{Dir.pwd}/test-db")
  puts db.start
end

desc "Get status of running CouchDB using gems"
task :status_couchdb do
  require "rubygems"
	require "memetic-couchdb"
  db = Memetic::CouchDB.new("#{Dir.pwd}/test-db")
  puts db.status
end

desc "Stop CouchDB using gems"
task :stop_couchdb do
  require "rubygems"
	require "memetic-couchdb"
  db = Memetic::CouchDB.new("#{Dir.pwd}/test-db")
  puts db.stop
end


task :live_modules do
	MODULES.each do |m|
		$LOAD_PATH << File.join(Dir.getwd, "modules", m, "lib")
	end
end

desc "Start CouchDB using the live modules i.e. not gems"
task :start_live_couchdb => [ :live_modules ]  do
	require "memetic-couchdb"
  db = Memetic::CouchDB.new("#{Dir.pwd}/test-db")
  puts db.start
end

desc "Get status of running CouchDB using the live modules i.e. not gems"
task :status_live_couchdb => [ :live_modules ] do
	require "memetic-couchdb"
  db = Memetic::CouchDB.new("#{Dir.pwd}/test-db")
  puts db.status
end

desc "Stop CouchDB using the live modules i.e. not gems"
task :stop_live_couchdb => [ :live_modules ] do
	require "memetic-couchdb"
  db = Memetic::CouchDB.new("#{Dir.pwd}/test-db")
  puts db.stop
end