String cron_string = BRANCH_NAME == 'master' ? 'H 3 * * *' : ''

def build_image = {
  sh '''
    ./debos-podman \
      "./$RECIPE" \
      --fakemachine-backend kvm \
      -m 12G \
      --cpus $(nproc --all) \
      -e "APT_PROXY:http://$(ip route get 8.8.8.8 | head -1 | cut -d\' \' -f7):3142" \
      -t "image:$IMAGE" -t "architecture:${ARCHITECTURE}"
  '''
  sh 'if [ "$POST_BUILD_XZ" = "1" ]; then xz -1f -Q --threads 0 "$IMAGE"; fi'
  sh 'echo "$(date -u +%Y-%m-%dT%H:%M:%SZ)_${ARCHITECTURE}_${GIT_BRANCH}_${BUILD_NUMBER}_${GIT_COMMIT}" | tee "${IMAGE}.build"'
  archiveArtifacts(artifacts: '*.tar.gz,*.xz,*.build,*.manifest', fingerprint: true, onlyIfSuccessful: true)
}

def check_for_changes = {
  sh 'git branch --force master $(git show-ref -s origin/master)'
  return sh (
    returnStatus: true,
    script: '! git diff --quiet $GIT_COMMIT origin/master -- focal/ scripts/ common/ Jenkinsfile'
  )
}

pipeline {
  agent none
  triggers {
    cron(cron_string)
  }
  options {
    buildDiscarder(logRotator(artifactNumToKeepStr: '30', numToKeepStr: '180'))
  }
  stages {
    stage('Rootfs builds') {
      matrix {
        agent none
        axes {
          axis {
            name 'VARIANT'
            values 'ubuntu-touch-hybris-rootfs', 'ubuntu-touch-android9plus-rootfs', 'ubuntu-touch-pdk-img'
          }

          axis {
            name 'ARCHITECTURE'
            values 'arm64', 'armhf', 'amd64'
          }
        }
        excludes {
          exclude {
              axis {
                  name 'VARIANT'
                  notValues 'ubuntu-touch-pdk-img'
              }
              axis {
                  name 'ARCHITECTURE'
                  values 'amd64'
              }
          }
          exclude {
              axis {
                  name 'VARIANT'
                  values 'ubuntu-touch-pdk-img'
              }
              axis {
                  name 'ARCHITECTURE'
                  values 'armhf'
              }
          }
        }

        stages {
          stage("Debos") {
            agent { label 'debos-amd64' } // Yes, ARM images are built on AMD64 too.
            when {
              beforeAgent false
              anyOf {
                branch 'master'
                expression { check_for_changes() == 0 }
              }
            }

            environment {
              RECIPE = "focal/${VARIANT}.yaml"
              IMAGE = "${VARIANT}-${ARCHITECTURE}.${VARIANT.endsWith("-rootfs") ? "tar.gz" : "raw"}"
              ARCHITECTURE = "${ARCHITECTURE}"
              POST_BUILD_XZ = "${VARIANT.endsWith("-img") ? "1" : ""}"
            }
            steps {
              script {build_image()}
            }
            post {
              cleanup {
                deleteDir()
              }
            }
          }
        }
      }
    }
  }
}
