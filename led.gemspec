Gem::Specification.new do |s|
  s.name        = 'led'
  s.version     = '0.3.0'
  s.date        = '2013-07-04'
  s.summary     = 'Redis ORM'
  s.description = 'Script-based ORM for Redis'
  s.authors     = ['Sharon Rosner']
  s.email       = 'ciconia@gmail.com'
  s.files       = ['lib/led.rb', 'lib/model.rb']
  s.homepage    = 'http://github.com/ciconia/led'
  
  s.add_dependency 'redis', '>= 3.0.0'
end