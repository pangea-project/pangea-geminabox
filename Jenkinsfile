env.GEM_HOME = '/var/lib/jenkins/.gem/ruby/2.2.0'
env.PATH = '/var/lib/jenkins/.gem/ruby/2.2.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/snap/bin'
env.GEM_PATH = '/var/lib/jenkins/.gem/ruby/2.2.0:/var/lib/jenkins/.gems/bundler'

parallel(
  "git[releaseme]": {
    cleanNode('master') {
      git_clone 'https://github.com/blue-systems/pangea-geminabox', 'geminabox'
      git_clone 'https://anongit.kde.org/releaseme', 'releaseme'
      sh 'ls -lah'
      sh 'ls -lah releaseme'
      sh "ruby geminabox/build_gem.rb `pwd`/releaseme"
    }
  },
  "git[gitlab]": {
    cleanNode('master') {
      git_clone 'https://github.com/blue-systems/pangea-geminabox', 'geminabox'
      git_clone 'https://github.com/NARKOZ/gitlab', 'gitlab'
      sh "ruby geminabox/build_gem.rb `pwd`/gitlab"
    }
  },
  "git[net-ssh]": {
    cleanNode('master') {
      git_clone 'https://github.com/blue-systems/pangea-geminabox', 'geminabox'
      git_clone 'https://github.com/net-ssh/net-ssh', 'net-ssh'
      sh "ruby geminabox/build_gem.rb `pwd`/net-ssh"
    }
  },
  "git[ci_reporter_test_unit]": {
    cleanNode('master') {
      git_clone 'https://github.com/blue-systems/pangea-geminabox', 'geminabox'
      git_clone 'https://github.com/apachelogger/ci_reporter_test_unit', 'ci_reporter_test_unit', 'test-unit-3'
      sh "ruby geminabox/build_gem.rb `pwd`/ci_reporter_test_unit"
    }
  }
)

def git_clone(url, dir, branch = 'master') {
  checkout([$class: 'GitSCM', branches: [[name: "*/${branch}"]], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: dir]], submoduleCfg: [], userRemoteConfigs: [[url: url]]])
}


def cleanNode(label = null, body) {
  node(label) {
    try {
      wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
        wrap([$class: 'TimestamperBuildWrapper']) {
          body()
        }
      }
    } finally {
      step([$class: 'WsCleanup', cleanWhenFailure: true])
    }
  }
}
