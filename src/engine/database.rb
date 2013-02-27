##
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
#

require 'active_record'

class Database

  def initialize(adapter, path)
    @params = { :adapter => adapter, :database  => path }
    ActiveRecord::Base.timestamped_migrations = false
  end

  def connect
    ActiveRecord::Base.establish_connection(@params)
    migrate
  end

private
  def migrate
    ActiveRecord::Migrator.up("src/engine/migrations")
  end

end
