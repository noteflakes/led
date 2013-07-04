require 'rubygems'
require 'bundler/setup'

require 'hiredis'
require 'redis'

require File.join(__dir__, 'model')

module Led
  def self.conn= (conn)
    @conn = conn
  end
  
  def self.conn
    @conn ||= Redis.new
  end
  
  def self.add_script(name, script)
    @shas ||= {}
    @scripts ||= {}

    script = preprocess(script)
    
    @shas[name.to_sym] = conn.script('load', script)
    @scripts[name.to_sym] = script
  end
  
  def self.method_missing(m, *args)
    unless @shas && @shas[m]
      @script_dir ? load_script(m) : super
    end
    
    run_script(m, *args)
  end
  
  def self.run_script(m, *args)
    conn.evalsha(@shas[m], [], args)
  rescue Redis::CommandError => e
    # detect if script needs to be reloaded
    if e.message =~ /NOSCRIPT/
      @shas[m] = conn.script('load', @scripts[m])
      conn.evalsha(@shas[m], [], args)
    else
      handle_command_error(e, m)
    end
  end
  
  def self.handle_command_error(e, method)
    if e.message =~ /^ERR.+user_script\:([0-9]+)\: (.+)$/
      raise e, "#{method}.lua:#{$1}: #{$2}"
    elsif e.message =~ /^([A-Z][a-zA-Z_0-9]+)(?:\:(.+))?/
      klass = (Object.const_get($1) rescue Redis::CommandError)
      raise klass, ($2 || '')
    else
      raise e
    end
  end
  
  def self.preprocess(script)
    script.
      # redis.call shorthand
      gsub(/([A-Z]+)\(/) {"redis.call('#{$1}',"}.
      # string interpolation
      gsub(/\#\{([^\}]+)\}/) {"\" .. #{$1} .. \""}.
      # remove empty string concatenation
      gsub(/\s\.\.\s''/, ' ').
      gsub(/[^\\]''\s\.\.\s/, ' ').
      gsub(/\__include '([^\s]+)'/) {process_include($1)}
  end
  
  def self.process_include(file)
    raise "Script directory not specified" unless @script_dir
    
    IO.read(File.join(@script_dir, "#{file}.lua"))
  end
  
  def self.script_dir=(dir)
    @script_dir = dir
  end
  
  def self.script_dir
    @script_dir
  end
  
  def self.load_script(name)
    script = IO.read(File.join(script_dir, "#{name}.lua"))
    add_script(name, script)
  end
end