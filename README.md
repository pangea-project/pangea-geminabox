# Purpose

Geminabox is a simple replacement for rubygems.org. It also has a fall-thru
proxy/cache capability.

For our purposes we use as an on-site cache of gems and also as native host of
from-git built gems. Because Bundler's git gemming isn't working particularly
well for use we're building gems we need from git elsewhere and push them
into the box so bundler can treat these gems just like any other gem.

# Provision

geminabox is provisioned by our kitchen.

# start.sh

It's the entry point of the systemd service. It does some initial startup
updating to make sure the stack is uptodate (and hopefully secure). Once updated
start.sh will exec unicorn.

# unicorn.rb

As webserver we are using unicorn (which in turn is proxied by apache in
deployment scenarios). unicorn.rb configures it.

# config.ru

Geminabox itself is a rack application which is spun up using config.ru. Actual
geminabox configuration happens there. Also, an authentication mechanism is
added to the core functionality. The authentication credentials are stored
in ~/.config/pangea_build_gem.yaml

# Auth

There's different auth credentials in use here. For the webui we use a HTTP
basic auth with username and password. For API usage we use a key for use in
~/.gem/credentials on the client-side.

# Git-builds

Jenkinsfile and build_gem.rb facilitiate building of a gem from git. Jenkinsfile
assembles the repos and uses build_gem to actually build and push the gem.

## build_gem

Building is fairly straight forward. We patch the `*.gemspec` found in the gem
repo to hijack the version definition. We'll then append a `.$date.$time` suffix
to differentiate our builds from potential upstream ones. Additionally this
ensures different versions across rebuilds. The datetime itself is derived from
the latest git commit and as such is persistent across rebuilds of the same
HEAD (and hopefully monotone increasing).

Once we have a gem we'll conduct some additional assertations to make sure our
build is in fact newer than what is in the box already.

If all is fine we `gem push` to our box. This requires ~/.gem/credentials to be
set up with our api key.

# Short comings

Presently we use a flat box for both caching and git-builds. This has a bit of
an advantage and a bit of a disadvantage. It's simple to use as there is only
one gem api which can be used as drop-in replacement for rubygems. This also
is its main problem though. If you `gem install foo` and foo has a newer version
in rubygems than we build with git-builds this version will be pulled in the
cache AND version override the git build. If this happens during auto-deployment
of our tooling this installs the new foo across the infrastructure at which
point the git-build MUST follow suit as the infrastructure at this point may
be broken from the new version. Also since the newer version is now rolled out
the git-build has no options but to bump version if that is in theory not right.

This could be solved by using a second box for only the git-builds and then
in the Gemfile do something like

```
source 'https://git.gem.cache.pangea.pub' do
  gem :foo
end
```

Which should grab foo from the git build and **lock** it at the version from
there, preventing other gems from pulling in a higher version from
another source (i.e. rubygems). If this actually works consistently like this
is unknown, and structure it is more work, so we are not doing this right now.
