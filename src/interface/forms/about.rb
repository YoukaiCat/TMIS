# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'Qt'
require_relative 'ui_about'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
include Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class AboutDialog < Qt::Dialog

  def initialize(parent = nil)
    super parent
    @ui = Ui::AboutDialog.new
    @ui.setup_ui self
    @ui.textBrowser.html += <<-HEREDOC.gsub(/^ {4}/, '')
    <p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;">
    Timetable Management Information System</p>
    <p style="-qt-paragraph-type:empty; margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;"><br /></p>
    <p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;">
    Информационная система управления расписанием, предназначенная для учебных заведений среднего и высшего профессионального образования.</p>
    <p style="-qt-paragraph-type:empty; margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;"><br /></p>
    <p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;">
    Copyright © 2012 Милешкин Владислав noein93@gmail.com</p>
    <p style="-qt-paragraph-type:empty; margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;"><br /></p>
    <p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;">
    TMIS является свободным программным обеспечением и распространяется на условиях GNU GPLv3. Текст лицензии можно найти в файле COPYING, а также по ссылке: www.gnu.org/licenses/gpl.</p></body></html>
    HEREDOC
  end

end
