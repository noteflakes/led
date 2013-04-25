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
    @shas[name.to_sym] = conn.script('load', script)
  end
  
  alias_method :orig_method_missing, :method_missing
  def self.method_missing(m, *args)
    if @shas && @shas[m]
      conn.evalsha(@shas[m], [], args)
    else
      orig_method_missing(m, *args)
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