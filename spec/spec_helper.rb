require './lib/led'

Led.conn.select 1 # use non-default db

RSpec.configure do |config|
  config.before(:all) do
    GC.disable
  end
  
  config.before(:each) do
    Led.conn.flushdb
  end

  config.after(:all) do
    Led.conn.flushdb
  end
end
