Gem::Specification.new do |s|
  s.name        = 'led'
  s.version     = '0.0.0'
  s.date        = '2013-04-24'
  s.summary     = 'Script Redis using Ruby!'
  s.description = 'Write your Redis business logic with Ruby'
  s.authors     = ['Sharon Rosner']
  s.email       = 'ciconia@gmail.com'
  s.files       = ['lib/led.rb']
  s.homepage    = 'http://github.com/ciconia/led'
  
  s.add_dependency 'redis', '>= 3.0.0'
  s.add_dependency 'ruby2ruby', '>= 2.0.4'
  s.add_dependency 'assistance', '>= 0.1.5'
  s.add_dependency 'metaid', '>= 1.0'
end