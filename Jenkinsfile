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
  "git[jenkins_junit_builder]": {
    cleanNode('master') {
      git_clone 'https://github.com/blue-systems/pangea-geminabox', 'geminabox'
      git_clone 'https://github.com/hsitter/jenkins_junit_builder', 'jenkins_junit_builder'
      sh 'ls -lah'
      sh 'ls -lah jenkins_junit_builder'
      sh "ruby geminabox/build_gem.rb `pwd`/jenkins_junit_builder"
    }
  },
  "git[jenkins_api_client]": {
    cleanNode('master') {
      git_clone 'https://github.com/blue-systems/pangea-geminabox', 'geminabox'
      git_clone 'https://github.com/bryan-kc/jenkins_api_client.git', 'jenkins_api_client'
      sh 'ls -lah'
      sh 'ls -lah jenkins_api_client'
      sh "ruby geminabox/build_gem.rb `pwd`/jenkins_api_client"
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
