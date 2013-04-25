require 'rubygems'
require 'bundler/setup'

require 'hiredis'
require 'redis'

module Led
  def self.conn= (conn)
    @conn = conn
  end
  
  def self.conn
    @conn ||= Redis.new
  end
  
  def self.add(name, script)
    @shas ||= {}
    @scripts ||= {}

    script = preprocess(script)
    
    @shas[name.to_sym] = conn.script('load', script)
    @scripts[name.to_sym] = script
  end
  
  alias_method :orig_method_missing, :method_missing
  def self.method_missing(m, *args)
    if @shas && @shas[m]
      conn.evalsha(@shas[m], [], args)
    else
      orig_method_missing(m, *args)
    end
  rescue Redis::CommandError => e
    # detect if script needs to be reloaded
    if e.message =~ /NOSCRIPT/
      @shas[m] = conn.script('load', @scripts[m])
      conn.evalsha(@shas[m], [], args)
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
      gsub(/[^\\]''\s\.\.\s/, ' ')
      # 
      # .replace(/\__include '([^\s]+)'/g, (m, name) => @loadScript("_include/#{name}.lua"))
    
  end
end