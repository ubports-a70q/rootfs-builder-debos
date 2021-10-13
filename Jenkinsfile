String cron_string = BRANCH_NAME == 'master' ? 'H 3 * * *' : ''

pipeline {
  agent none
  triggers {
    // Trigger once a day between 3AM and 4AM
    cron(cron_string)
  }
  options {
    buildDiscarder(logRotator(artifactNumToKeepStr: '30', numToKeepStr: '180'))
  }
  stages {
    stage('focal') {
      agent { label 'debos-amd64' }
      steps {
        // debos podman NEEDS /etc/apt-cacher-ng/99-ubports.conf!
        sh './debos-podman focal/ubuntu-touch-hybris-rootfs.yaml --fakemachine-backend=kvm -m 2G --scratchsize 10G --cpus $(nproc --all) -e "http_proxy:http://$(ip route get 8.8.8.8 | head -1 | cut -d\' \' -f7):3142"'
        sh 'echo "$(date -u +%Y-%m-%dT%H:%M:%SZ)_arm64_${GIT_BRANCH}_${BUILD_NUMBER}_${GIT_COMMIT}" | tee ubuntu-touch-hybris-rootfs-arm64.tar.gz.build'

        archiveArtifacts(artifacts: '*.tar.gz,*.build', fingerprint: true, onlyIfSuccessful: true)
      }
      post {
        cleanup {
          deleteDir() /* clean up our workspace */
        }
      }
    }
  }
}
