Gem::Specification.new do |s|
  s.name        = 'led'
  s.version     = '0.2.0'
  s.date        = '2013-04-30'
  s.summary     = 'Redis script preprocessor'
  s.description = 'Easy Lua scripting for Redis'
  s.authors     = ['Sharon Rosner']
  s.email       = 'ciconia@gmail.com'
  s.files       = ['lib/led.rb']
  s.homepage    = 'http://github.com/ciconia/led'
  
  s.add_dependency 'redis', '>= 3.0.0'
end