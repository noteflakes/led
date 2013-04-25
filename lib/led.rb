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
  # 
  # def self.exec(ruby_source)
  #   lua_source = Led::Translator.translate(ruby_source)
  #   puts "*****************************"
  #   p lua_source
  #   conn.eval(lua_source)
  # end
end