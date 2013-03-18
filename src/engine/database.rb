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
require 'active_record'
require 'singleton'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class Database
  include Singleton

  attr_reader :path

  def connect_to(path)
    @path = path
    if ActiveRecord::Base.connected?
      connect(path)
    else
      ActiveRecord::Base.remove_connection
      connect(path)
    end
    self
  end

  def connected?
    ActiveRecord::Base.connected?
  end

  def disconnect
    ActiveRecord::Base.remove_connection
  end

  def transaction(&block)
    ActiveRecord::Base.transaction(&block)
  end

private
  def connect(path)
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: path)
    ActiveRecord::Base.timestamped_migrations = false
    ActiveRecord::Migrator.up("src/engine/migrations")
  end
end
