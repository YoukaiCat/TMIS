#!/usr/bin/env ruby
# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Copyright (C) 2013 Vladislav Mileshkin
#
# This file is part of TMIS.
#
# TMIS is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# TMIS is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with TMIS. If not, see <http://www.gnu.org/licenses/>.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'Qt'
require_relative 'tmis/interface/mainwindow'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Encoding.default_external = 'UTF-8'
#Encoding.default_internal = 'UTF-8'

Qt.debug_level = Qt::DebugLevel::High if ARGV.include? "--debug"
#Qt::Internal::setDebug(Qt::QtDebugChannel::QTDB_VIRTUAL)
#Qt::Internal::setDebug(Qt::QtDebugChannel::QTDB_GC)

class TMIS
  def self.run
    Qt::Application.new(ARGV) do
      codec = Qt::TextCodec::codecForName('UTF-8')
      Qt::TextCodec::setCodecForCStrings codec
      Qt::TextCodec::setCodecForLocale codec
      Qt::TextCodec::setCodecForTr codec
      translator = Qt::Translator.new(self)
      translator.load('qt_ru', Qt::LibraryInfo::location(Qt::LibraryInfo::TranslationsPath))
      installTranslator(translator)
      MainWindow.new.show
      exec
    end
  end
end
