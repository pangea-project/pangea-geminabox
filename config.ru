# frozen_string_literal: true
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2017-2020 Harald Sitter <sitter@kde.org>

require 'rubygems'
require 'geminabox'
require 'unicorn/worker_killer'

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



use Unicorn::WorkerKiller::MaxRequests, 3072, 4096
use Unicorn::WorkerKiller::Oom, (100*(1024**2)), (128*(1024**2))

# disable legacy index for rubygems<1.2 to speed things up
Geminabox.build_legacy = false

run Geminabox::Server