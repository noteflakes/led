require File.join(__dir__, 'spec_helper')
require 'fileutils'

describe 'Led.add' do
  it 'should pre-process the scripts' do
    Led.add_script(:t1, 'return 1')
    
    Led.t1.should == 1
  end
  
  it 'should pass arguments correctly' do
    Led.add_script(:t2, 'return ARGV')
    
    Led.t2(1,2,3).should == %w{1 2 3}
  end
end

describe 'Led' do
  it 'should reload the script automatically if missing' do
    Led.add_script(:t1, 'return 1')
    Led.t1.should == 1
    
    Led.conn.script('flush')
    
    Led.t1.should == 1
  end
end

describe 'Led.preprocess' do
  it 'should interpolate strings correctly' do
    Led.add_script(:t1, 'return "abc#{ARGV[1]}"')
    Led.t1('def').should == 'abcdef'

    
    Led.add_script(:t1, 'local s = "abc#{ARGV[1]}";return "#{s}:#{ARGV[2]}"')
    Led.t1('def', 'ghi').should == 'abcdef:ghi'
  end
  
  it 'should convert redis.call shortcuts' do
    Led.add_script(:t1, 'SET(ARGV[1], ARGV[2])')
    Led.t1('abc', 'def')
    
    Led.conn.get('abc').should == 'def'
  end
end

describe "Led.script_dir" do
  before do
    lua =<<EOF
    
      local stamp = tonumber(ARGV[1])
      SET('stamp', stamp)
      
      return GET('stamp')
EOF
  
    IO.write('test.lua', lua)

    Led.script_dir = '.'
  end
  
  after do
    FileUtils.rm(Dir.glob('*.lua')) rescue nil
  end
  
  it 'should allow automatic loading of scripts' do
    proc {Led.test(123)}.should_not raise_error
    
    Led.conn.get('stamp').should == '123'
  end
  
  it 'should allow includes in scripts' do
    func =<<EOF
    local function add(x, y)
      return x + y
    end
EOF
    IO.write('helpers.lua', func)
  
    test_include =<<EOF
      __include 'helpers'
      
      local x = tonumber(ARGV[1])
      local y = tonumber(ARGV[2])
      return add(x, y)
EOF
    Led.add_script(:test_include, test_include)

    Led.test_include(123, 456).should == 579
  end
end