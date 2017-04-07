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

require 'fileutils'
require 'tmpdir'
require 'yaml'

require_relative 'config'

# Mangles a gemspec file so we can build it into something sane.
class GemSpecMangler
  attr_reader :path
  attr_reader :new_path

  def self.find_file(dir)
    gemspecs = Dir.glob("#{dir}/*.gemspec")
    raise "too many gemspecs #{gemspecs}" if gemspecs.size > 1
    raise "couldnt find gemspec file in #{Dir.pwd}" if gemspecs.empty?
    gemspecs[0]
  end

  def initialize(path = self.class.find_file)
    @path = File.absolute_path(path)
    @new_path = "#{path}.new"
  end

  def mangle!
    injected = false
    File.open(new_path, 'w') do |out|
      File.open(path).each_line do |line|
        if line.strip.start_with?('#') || injected
          out.write(line)
          next
        end
        # The line is the first line that is not a comment whilest not having
        # injected our magic.
        injected = true
        # We mangle the spec data generated later in the gemspec file by
        # disabling and all push restrictions and setting an ever increasing
        # version
        out.write(File.read("#{__dir__}/mangler.template"))
        out.write(line)
      end
    end
  end
end

dir = ARGV[0]

FileUtils.rm_rf('pangeapkg')
Dir.mktmpdir do |tmpdir|
  Dir.chdir(tmpdir) do
    spec = GemSpecMangler.new(GemSpecMangler.find_file(dir))
    spec.mangle!
    system('gem', 'build', spec.new_path, '-V') || raise
    system('gem', 'push', Dir.glob('*.gem').fetch(0),
           '-V',
           '--host', Config.host)
  end
end
