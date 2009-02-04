module Memetic
  
  module Erlang
    
    DIRECTORY = %x{cd #{File.dirname(File.dirname(__FILE__)) + "/BUILD"} ; pwd}.split()[0]
    
    def Erlang.configure_environment(env)
      env.add_binary_path("#{DIRECTORY}/lib/erlang/bin")
      env.set_variable("ERLANG_ROOT", DIRECTORY)
    end

  end

end