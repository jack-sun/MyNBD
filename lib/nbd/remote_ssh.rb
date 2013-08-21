require 'timeout'
 
module NBD::RemoteSsh
  # Attempt to ping a remote machine
  # If command executes then ping successful
  # If used with a block the block will be ran if the machine was able to ping
  # ex
  # ping("guy", "guyhost.com") do
  #   run_command("ls -la")
  # end
  def ping(user, host, &block)
    begin
      ping_output = []
      timeout(20) do
        ping_output = IO.popen("ssh #{user}@#{host} 'echo \"pong\"'", "w+")
      end
      ping = ping_output.readlines.join[/pong/] ? true : false
    rescue Timeout::Error
      ping = false
    rescue
      ping = false
    end
    ping_output.close
    if block_given? && ping
      yield
    end
    return ping
  end
 
  # run any command on a remote machine and return the results
  def run_command(user, host, cmd)
    ping(user, host) do
      my_text = IO.popen("ssh #{user}@#{host} 'bash'", "w+")
      my_text.write(cmd)
      my_text.close_write
      my_rtn = my_text.readlines.join('\n')
      Process.wait(my_text.pid)
      my_text.close
      return my_rtn
    end
  end
 
  # Save a file to a remote machine by sending the io stream and the path name
  # ie save_local("tmp/my_path.txt", "hello world")
  def save_local(place_path, io)
    file_saved = true
    begin
      file = open(place_path, "w")
      file.write(io.read)
      file.close
    rescue => e
      file_saved = false
    end
    return file_saved
  end
 
  # Do the ssh connection and open a file for writing. Then write the body and close.
  def write_body(user, host, body, paste_path, sudo = false)
    ping(user, host) do
      begin
        set_config = IO.popen("ssh #{user}@#{host} 'cat > \"#{paste_path}\"'", "w+")
        set_config.write("sudo bash -c 'cat > #{paste_path}'\n") if sudo
        set_config.write(body)
        set_config.close
      rescue
        "Transmission failed"
      end
    end
  end
 
  # Take a file from your connection point and place it to a remote machine
  def push_file(user, host, copy_path, paste_path, sudo = false)
    ping(user, host) do
      begin
        file = open(copy_path)
        write_body(user, host, file.read(File.size(copy_path)), paste_path)
        file.close if file
      rescue
        "No such file."
      end
    end
  end
 
  # Take a remote machine file and copy to current connection point
  def pull_file(user, host, copy_path, place_path, sudo = false)
    ping(user, host) do
      begin
        my_text = IO.popen("ssh #{user}@#{host} 'cat \"#{copy_path}\"'")
        my_text.write("sudo bash -c 'cat #{copy_path}'\n") if sudo
        file_saved = save_local(place_path, my_text)
        my_text.close
        return file_saved
      rescue
         "No such file."
      end
    end
  end
end