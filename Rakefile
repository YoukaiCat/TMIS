task :test => [:compile, :rspec]
task :default => [:test]

task :compile do
  compile_form 'src/interface/mainwindow.ui'
  compile_form 'src/interface/forms/settings.ui'
  compile_form 'src/interface/forms/import.ui'
  compile_form 'src/interface/forms/export_general_timetable.ui'
  compile_form 'src/interface/forms/export_lecturer_timetable.ui'
  compile_form 'src/interface/forms/export_group_timetable.ui'
  compile_form 'src/interface/forms/edit_study.ui'
  compile_form 'src/interface/forms/console.ui'
  compile_form 'src/interface/forms/about.ui'
end

task :clean do
  rm 'src/interface/ui_mainwindow.rb'
  rm 'src/interface/forms/ui_settings.rb'
  rm 'src/interface/forms/ui_import.rb'
  rm 'src/interface/forms/ui_export_general_timetable.rb'
  rm 'src/interface/forms/ui_export_lecturer_timetable.rb'
  rm 'src/interface/forms/ui_export_group_timetable.rb'
  rm 'src/interface/forms/ui_edit_study.rb'
  rm 'src/interface/forms/ui_console.rb'
  rm 'src/interface/forms/ui_about.rb'
end

task :rspec do
  rspec
end

def rbuic4(arg)
  puts "rbuic4 #{arg}"
  %x[rbuic4 #{arg}]
end

def compile_form(path)
  path[/([a-z_0-9\/]+\/)([a-z_0-9\.]+)/i]
  dirs, file = $1, $2
  rbuic4(path << ' -o ' << dirs << 'ui_' << file.sub('.ui', '.rb'))
end

def rspec(arg='')
  puts %x[rspec #{arg}]
end
