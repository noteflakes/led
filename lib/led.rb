require 'rubygems'
require 'bundler/setup'

require 'hiredis'
require 'redis'

require 'require_all'

require_rel 'led'

module Led
  def self.conn= (conn)
    @conn = conn
  end
  
  def self.conn
    @conn ||= Redis.new
  end
  
  def self.exec(ruby_source)
    lua_source = Led::Translator.translate(ruby_source)
    puts "*****************************"
    p lua_source
    conn.eval(lua_source)
  end
end