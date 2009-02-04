module Memetic
  
  module PCRE
    
    DIRECTORY = %x{cd #{File.dirname(File.dirname(__FILE__)) + "/BUILD"} ; pwd}.split()[0]
    
    def PCRE.configure_environment(env)
      env.add_binary_path("#{DIRECTORY}/bin")
      env.add_library_path("#{DIRECTORY}/lib")
    end

  end

end