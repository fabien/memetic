require 'memetic'
require 'memetic-erlang'
require 'memetic-spidermonkey'
require 'memetic-icu'

module Memetic
  
  class CouchDB
    
    DIRECTORY = %x{cd #{File.dirname(File.dirname(__FILE__)) + "/BUILD"} ; pwd}.split()[0]
      
    def CouchDB.configure_environment(env)
      Erlang.configure_environment(env)
      Spidermonkey.configure_environment(env)
      ICU.configure_environment(env)
    end
      
    # TODO: set a port to enable multiple concurrent instances
    def initialize(local_directory)
      @local_directory = local_directory
      Dir.mkdir(@local_directory) unless File.exists?(@local_directory)

      @log_directory = "#{@local_directory}/log"
      Dir.mkdir(@log_directory) unless File.exists?(@log_directory)

      @data_directory = "#{@local_directory}/data"
      Dir.mkdir(@data_directory) unless File.exists?(@data_directory)

      File.open("#{@local_directory}/configuration.ini", "w") do |f|
        f << configuration()
      end
    end
    
    def start
      env = Environment.new
      CouchDB.configure_environment(env)
      cmd = env.as_command_prefix
      cmd << "( cd '#{DIRECTORY}' ; "
      cmd << "./bin/couchdb -b "
      cmd << "-o '#{@log_directory}/couchdb.stdout' "
      cmd << "-e '#{@log_directory}/couchdb.stderr' "
      cmd << "-p '#{@local_directory}/pid' "
      cmd << "-c './etc/couchdb/default.ini' "
      cmd << "-c '#{@local_directory}/configuration.ini' "
      cmd << " )"
      s = ""
      IO.popen(cmd) do |p|
        s = p.gets
        s.chomp if s
      end
    end
    
    def status
      env = Environment.new
      CouchDB.configure_environment(env)
      IO.popen("#{env.as_command_prefix} #{DIRECTORY}/bin/couchdb -p #{@local_directory}/pid -s") do |p|
        s = p.gets
        s.chomp if s
      end
    end
    
    def stop
      env = Environment.new
      CouchDB.configure_environment(env)
      IO.popen("#{env.as_command_prefix} #{DIRECTORY}/bin/couchdb -p #{@local_directory}/pid -d") do |p|
        s = p.gets
        s.chomp if s
      end
    end

    def configuration
      return <<END_OF_STRING
[couchdb]
database_dir = #{@data_directory}

[log]
file = #{@log_directory}/couch.log
level = debug
END_OF_STRING
    end

  end

end