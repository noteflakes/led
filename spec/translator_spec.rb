describe 'The ruby-lua translator' do
  it 'should translate to executable lua in Redis' do
    Led.exec("return 1").should == 1
  end
  
  it "should support implicit return" do
    Led.exec("1").should == 1
  end
  
  it "should support literals" do
    Led.exec("1234").should == 1234
    # Led.exec("654.321").should == 654.321
    Led.exec("nil").should == nil
    Led.exec("'abc'").should == 'abc'
    Led.exec("true").should == 1
    Led.exec("false").should == 0
  end
end