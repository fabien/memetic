raise "I can't handle this platform: #{RUBY_PLATFORM}" unless RUBY_PLATFORM =~ /darwin/

module Memetic
  
  class Environment
    
    def initialize
      @binary_path = []
      @library_path = []
      @variables = {}
    end
    
    def add_binary_path(path)
      @binary_path << path
    end
    
    def add_library_path(path)
      @library_path << path
    end
    
    def set_variable(name, value)
      @variables[name] = value
    end
    
    def as_command_prefix
      prefix = ""
      
      if (!@binary_path.empty?)
        prefix << "export PATH='"
        @binary_path.each do |p|
          prefix << p << ':'
        end
        prefix << "/usr/bin:/usr/sbin:/bin:/sbin'; "
      end
      
      if (!@library_path.empty?)
        prefix << "export DYLD_LIBRARY_PATH='"
        @library_path.each do |p|
          prefix << p << ':'
        end
        prefix.chop!
        prefix << "'; "
      end
      
      if (!@variables.empty?)
        @variables.each do |k,v|
          prefix << "export #{k}='#{v}'; "
        end
      end
      
      return prefix
    end
    
  end
  
end