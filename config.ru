# frozen_string_literal: true
#
# Copyright © 2017 Harald Sitter <sitter@kde.org>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License or (at your option) version 3 or any later version
# accepted by the membership of KDE e.V. (or its successor approved
# by the membership of KDE e.V.), which shall act as a proxy
# defined in Section 14 of version 3 of the license.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'rubygems'
require 'geminabox'

require_relative 'config'

CREDENTIALS = [Config.user, Config.password].freeze
API_KEY = Config.api_key.freeze

# WARNING: configuration needs to happen before we call any methods class-level
#   or object-level, it does not matter.
Dir.mkdir('data') unless Dir.exist?('data')
Geminabox.data = File.absolute_path('data') # ... or wherever
Geminabox.rubygems_proxy = true

Geminabox::Server.helpers do
  def guard!
    request.path.start_with?('/api') ? api_guard! : web_guard!
  end

  def web_guard!
    return if web_authorized?
    response['WWW-Authenticate'] = %(Basic realm="Geminabox")
    halt 401, "Need to authenticate to manipulate stuff.\n"
  end

  def api_guard!
    return if api_authorized?
    halt 401, "API_KEY in HTTP_AUTHORIZATION invalid or missing.\n"
  end

  def api_authorized?
    env['HTTP_AUTHORIZATION'] == API_KEY
  end

  def web_authorized?
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == CREDENTIALS
  end
end

Geminabox::Server.before do
  p request.path
  next if request.safe?
  guard!
end

run Geminabox::Server
