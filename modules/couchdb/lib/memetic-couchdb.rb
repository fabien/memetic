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
      
    def initialize(local_directory)
      @local_directory = local_directory
      @log_directory = "#{@local_directory}/log"
      @data_directory = "#{@local_directory}/data"

      @configuration = {}
      @erlang_path = []
      
      add_configuration("couchdb", "database_dir", @data_directory)
      add_configuration("log", "file", "#{@log_directory}/couch.log")
      add_configuration("log", "level", "debug")
    end
    
    def add_configuration(section, name, value)
      @configuration[section] ||= {}
      @configuration[section][name] = value
    end
    
    def add_external(name, path)
      add_configuration("external", name, path)
      add_configuration("httpd_db_handlers", "_#{name}", "{couch_httpd_external, handle_external_req, <<\"#{name}\">>}")
    end
    
    def add_erlang_path(path)
      @erlang_path << path
    end
    
    def start
      Dir.mkdir(@local_directory) unless File.exists?(@local_directory)
      Dir.mkdir(@log_directory) unless File.exists?(@log_directory)
      Dir.mkdir(@data_directory) unless File.exists?(@data_directory)

      File.open("#{@local_directory}/configuration.ini", "w") do |f|
        f << configuration()
      end

      IO.popen(command_line()) do |p|
        s = p.gets
        s.chomp if s
      end
    end
    
    def show_config
      puts configuration()
      puts command_line()
      puts
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
    
    def command_line
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
      
      cmd
    end

    def configuration
      config = ""
      @configuration.each do |k,v|
        config << "[#{k}]\n"
        v.each do |k2,v2|
          config << "#{k2} = #{v2}\n"
        end
        config << "\n"
      end
      config
    end

  end

end