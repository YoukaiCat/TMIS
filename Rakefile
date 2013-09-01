require 'rake/testtask'
require 'rspec/core/rake_task'

def rbuic4(arg)
  puts "rbuic4 #{arg}"
  %x[rbuic4 #{arg}]
end

def compile_form(path)
  path = "lib/tmis/" + path
  path[/([a-z_0-9\/]+\/)([a-z_0-9\.]+)/i]
  dirs, file = $1, $2
  rbuic4(path << ' -o ' << dirs << 'ui_' << file.sub('.ui', '.rb'))
end

def remove_form(path)
  rm ("lib/tmis/" + path)
end

desc "Run tests"

#Rake::TestTask.new do |t|
#  t.libs << 'test'
#  t.libs << 'lib/tmis'
#end

task :test => [:compile, :spec]
task :default => [:test]

task :spec do
  puts %x[rspec]
end

#RSpec::Core::RakeTask.new(:spec)

task :compile do
  compile_form 'interface/mainwindow.ui'
  compile_form 'interface/forms/settings.ui'
  compile_form 'interface/forms/import.ui'
  compile_form 'interface/forms/export_general_timetable.ui'
  compile_form 'interface/forms/export_lecturer_timetable.ui'
  compile_form 'interface/forms/export_group_timetable.ui'
  compile_form 'interface/forms/edit_study.ui'
  compile_form 'interface/forms/console.ui'
  compile_form 'interface/forms/about.ui'
  compile_form 'interface/forms/expand_changes.ui'
  compile_form 'interface/forms/find.ui'
  compile_form 'interface/forms/debug_console.ui'
end

task :clean do
  remove_form 'interface/ui_mainwindow.rb'
  remove_form 'interface/forms/ui_settings.rb'
  remove_form 'interface/forms/ui_import.rb'
  remove_form 'interface/forms/ui_export_general_timetable.rb'
  remove_form 'interface/forms/ui_export_lecturer_timetable.rb'
  remove_form 'interface/forms/ui_export_group_timetable.rb'
  remove_form 'interface/forms/ui_edit_study.rb'
  remove_form 'interface/forms/ui_console.rb'
  remove_form 'interface/forms/ui_about.rb'
  remove_form 'interface/forms/ui_expand_changes.rb'
  remove_form 'interface/forms/ui_find.rb'
  remove_form 'interface/forms/ui_debug_console.rb'
end
