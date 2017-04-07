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

# NOTE: a web research suggested that unicorn natively can do a zero-downtime
#   handover between instances, I am not convinced that is in fact the case
#   but I am also too lazy to verify and it probably doesn't matter for the
#   use case at hand
#   https://bogomips.org/unicorn-public/6467961.dv7BxevMDL@debstor/t/

working_directory ENV['USER'] == 'geminabox' ? Dir.home : __dir__

worker_processes 4 # FIXME: best had scaled for cores I should think.
preload_app true
timeout 30

# Nobody knows if this is relevant.
# http://www.rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)
