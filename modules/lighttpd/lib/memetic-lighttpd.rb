require 'memetic-pcre'

module Memetic
  
  module Lighttpd
    
    DIRECTORY = %x{cd #{File.dirname(File.dirname(__FILE__)) + "/BUILD"} ; pwd}.split()[0]
    
    def Lighttpd.configure_environment(env)
      PCRE.configure_environment(env)
      env.add_binary_path("#{DIRECTORY}/bin")
      env.add_library_path("#{DIRECTORY}/lib")
    end

  end

end