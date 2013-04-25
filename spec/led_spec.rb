describe 'Led.add' do
  it 'should pre-process the scripts' do
    Led.add(:t1, 'return 1')
    
    Led.t1.should == 1
  end
  
  it 'should pass arguments correctly' do
    Led.add(:t2, 'return ARGV')
    
    Led.t2(1,2,3).should == %w{1 2 3}
  end
end

describe 'Led' do
  it 'should reload the script automatically if missing' do
    Led.add(:t1, 'return 1')
    Led.t1.should == 1
    
    Led.conn.script('flush')
    
    Led.t1.should == 1
  end
end

describe 'Led.preprocess' do
  it 'should interpolate strings correctly' do
    Led.add(:t1, 'return "abc#{ARGV[1]}"')
    Led.t1('def').should == 'abcdef'

    
    Led.add(:t1, 'local s = "abc#{ARGV[1]}";return "#{s}:#{ARGV[2]}"')
    Led.t1('def', 'ghi').should == 'abcdef:ghi'
  end
  
  it 'should convert redis.call shortcuts' do
    Led.add(:t1, 'SET(ARGV[1], ARGV[2])')
    Led.t1('abc', 'def')
    
    Led.conn.get('abc').should == 'def'
  end
end