Easy Lua scripting for Redis
============================

Led makes managing Redis Lua scripts simple and easy. Features:

- Install scripts as Ruby methods:

    Led.add_script(:add, 'return tonumber(ARGV[1])+tonumber(ARGV[2])')
    Led.add(12, 34) # => 46
    
- String interpolation for lua:

    Led.add_script(:interpolate, 'return "abc_#{ARGV[1]}"')
    Led.interpolate('def') # => "abc_def"

- Shorthand for redis calls:

    Led.add_script(:set, 'SET(ARGV[1], ARGV[2])') # silly example, I know
                          # same as redis.call('set', ARGV[1], ARGV[2])
                          
- Reuse code by using includes:

    # helpers.lua
    local function add(x, y)
      return x + y
    end
    
    # test.lua
    __include 'helpers'
    return add(ARGV[1], ARGV[2])
    
    # ruby
    Led.script_dir = '.' 
    # once the script dir is set, scripts files are loaded automatically.
    Led.test(1, 2) # => 3
    
# Installing

    gem install led
    
