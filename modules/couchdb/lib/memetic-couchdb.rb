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
      @externals = {}
      @erlang_path = []
    end
    
    def add_external(name, path)
      @externals[name] = path
    end
    
    def add_erlang_path(path)
      @erlang_path << path
    end
    
    def start
      Dir.mkdir(@local_directory) unless File.exists?(@local_directory)

      @log_directory = "#{@local_directory}/log"
      Dir.mkdir(@log_directory) unless File.exists?(@log_directory)

      @data_directory = "#{@local_directory}/data"
      Dir.mkdir(@data_directory) unless File.exists?(@data_directory)

      File.open("#{@local_directory}/configuration.ini", "w") do |f|
        f << configuration()
      end
      
      puts(IO.read("#{@local_directory}/configuration.ini"))

      env = Environment.new
      CouchDB.configure_environment(env)
      cmd = env.as_command_prefix
      cmd << "( cd '#{DIRECTORY}' ; "
      
      unless @erlang_path.empty?
        cmd << "ERL_AFLAGS='-pa"
        @erlang_path.each {|x| cmd << " \"#{x}\"" }
        cmd << "' "
      end
      
      cmd << "./bin/couchdb -b "
      cmd << "-o '#{@log_directory}/couchdb.stdout' "
      cmd << "-e '#{@log_directory}/couchdb.stderr' "
      cmd << "-p '#{@local_directory}/pid' "
      cmd << "-c './etc/couchdb/default.ini' "
      cmd << "-c '#{@local_directory}/configuration.ini' "
      cmd << " )"

      puts(cmd)
      puts

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
      config = <<END_OF_STRING
[couchdb]
database_dir = #{@data_directory}

[log]
file = #{@log_directory}/couch.log
level = debug
END_OF_STRING
  
      config << "\n[external]\n"
      @externals.each do |k,v|
        config << "#{k} = #{v}\n"
      end

      config << "\n[httpd_db_handlers]\n"
      @externals.each do |k,v|
        config << "_#{k} = {couch_httpd_external, handle_external_req, <<\"#{k}\">>}\n"
      end

      config << "\n"
      
      config
    end

  end

end