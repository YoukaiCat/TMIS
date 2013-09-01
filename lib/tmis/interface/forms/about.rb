# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'Qt'
require_relative 'ui_about'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
#include Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class AboutDialog < Qt::Dialog

  def initialize(parent = nil)
    super parent
    @ui = Ui::AboutDialog.new
    @ui.setup_ui self
    @ui.textBrowser.html += <<-HEREDOC.gsub(/^ {4}/, '')
    <p>Timetable Management Information System</p>
    Версия: 0.1
    <p>Информационная система управления расписанием, предназначенная для учебных заведений среднего профессионального образования.</p>
    <p>Copyright © 2012 Милешкин Владислав noein93@gmail.com</p>
    <p>TMIS является свободным программным обеспечением и распространяется на условиях GNU GPLv3. Текст лицензии можно найти в файле COPYING, а также по ссылке: www.gnu.org/licenses/gpl.</p>
    HEREDOC
  end

end
