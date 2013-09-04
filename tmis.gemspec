require 'rake'

# Compile UI before creating gem
app = Rake.application
app.init
app.load_rakefile
app['compile'].invoke

Gem::Specification.new do |spec|
  spec.name        = 'tmis'
  spec.version     = '0.1.4'
  spec.date        = '2013-01-09'
  spec.summary     = "TMIS"
  spec.description = "Timetable management information system"
  spec.authors     = ["Vladislav Mileshkin"]
  spec.email       = 'noein93@gmail.com'
  spec.homepage    = 'https://github.com/Noein/TMIS'
  spec.license     = 'GPLv3'
  spec.files       = Dir['lib/**/*.rb'] + Dir['spec/**/*'] + %w(README.md COPYING Rakefile)
  spec.executables << 'tmis'

  spec.required_ruby_version = '>= 1.9.1'

  spec.add_runtime_dependency 'qtbindings', '>= 4.8.3.0'
  spec.add_runtime_dependency 'sqlite3', '>= 1.3.8'
  spec.add_runtime_dependency 'activerecord', '>= 4.0.0'
  spec.add_runtime_dependency 'spreadsheet', '>= 0.8.9'
  spec.add_runtime_dependency 'roo', '>= 1.12.1'
  spec.add_runtime_dependency 'mail', '>= 2.5.4'
  spec.add_runtime_dependency 'contracts', '>= 0.2.3'
  # Dependencies that aren't managed by any of the gems, but required by them:
  spec.add_runtime_dependency 'zip', '>= 2.0.2'

  spec.add_development_dependency 'rspec', '>= 2.14.1'
  spec.add_development_dependency 'factory_girl', '>= 4.2.0'
  spec.add_development_dependency 'simplecov', '>= 0.7.1'
end
