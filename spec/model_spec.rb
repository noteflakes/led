require File.join(__dir__, 'spec_helper')

class Person < Led::Model
  set_primary_key :name
end

describe 'Led::Model.primary_key' do
  it 'should default to :id' do
    class Model1 < Led::Model
    end
    
    Model1.primary_key.should == :id
  end
  
  it 'should be settable using set_primary_key' do
    Person.primary_key.should == :name
  end
  
  it 'should be used as the search key in Model.[]' do
    e = Person.create(:name => 'Emanuel', :age => 5)
    n = Person.create(:name => 'Noa', :age => 4)
    
    m = Person['Emanuel']
    m.age.should == 5
  end
  
  it 'should be used to store the model' do
    Led.conn.hkeys(Person.object_map_key).should == []

    e = Person.create(:name => 'Emanuel', :age => 5)
    Led.conn.hkeys(Person.object_map_key).should == ['Emanuel']
    
    n = Person.create(:name => 'Noa', :age => 4)
    Led.conn.hkeys(Person.object_map_key).should == ['Emanuel', 'Noa']
  end
  
  it 'should be mutable' do
    e = Person.create(:name => 'Joseph')
    Led.conn.hkeys(Person.object_map_key).should == ['Joseph']
    
    e.name = 'Josephine'
    e.save
    
    Led.conn.hkeys(Person.object_map_key).should == ['Josephine']
  end
end

describe 'Led::Model.save' do
  it 'should save all object attributes' do
    e = Person.create(:name => 'Emanuel', :age => 5)
    s = Led.conn.hget(Person.object_map_key, 'Emanuel')
    s.should_not be_nil
    j = JSON.parse(s)
    j["name"].should == 'Emanuel'
    j["age"].should == 5
  end
  
  it 'should update defined indexes' do
    class Person2 < Person
      add_index :sex
    end
    
    p = Person2.create(:name => 'Emanuel', :sex => 'male')
    
    objects = Person2.filter(:sex => 'male')
    objects.should == [p]
  end
end