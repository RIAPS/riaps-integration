pipeline {
  agent any
  options {
    buildDiscarder logRotator(daysToKeepStr: '30', numToKeepStr: '30')
  }
  stages {
    stage('Fetch packages') {
      steps {
        withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_OAUTH_TOKEN')]) {
          sh '''#!/bin/bash
            wget https://github.com/gruntwork-io/fetch/releases/download/v0.1.1/fetch_linux_amd64
            chmod +x fetch_linux_amd64
            source version.sh
            ./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-core" --tag=$coreversion --release-asset="riaps-core-amd64.deb" .
            ./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-core" --tag=$coreversion --release-asset="riaps-core-armhf.deb" .
            ./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-pycom" --tag=$pycomversion --release-asset="riaps-pycom-amd64.deb" .
            ./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-pycom" --tag=$pycomversion --release-asset="riaps-pycom-armhf.deb" .
            ./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-timesync" --tag=$timesyncversion --release-asset="riaps-timesync-amd64.deb" .
            ./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-timesync" --tag=$timesyncversion --release-asset="riaps-timesync-armhf.deb" .
          '''
        }
      }
    }
    stage('Package') {
      steps {
        sh '''#!/bin/bash
          source version.sh
          mkdir riaps-release
          cp riaps-core-amd64.deb riaps-core-armhf.deb riaps-pycom-amd64.deb riaps-pycom-armhf.deb riaps-timesync-amd64.deb riaps-timesync-armhf.deb riaps-release/.
          echo "coreversion=$coreversion" >> riaps-release/manifest.txt
          echo "pycomversion=$pycomversion" >> riaps-release/manifest.txt
          echo "timesyncversion=$timesyncversion" >> riaps-release/manifest.txt
          tar cvzf riaps-release.tar.gz riaps-release
          cp version.sh riaps-x86runtime/.
          tar cvzf riaps-x86runtime.tar.gz riaps-x86runtime
          cp version.sh riaps-bbbruntime/.
          tar cvzf riaps-bbbruntime.tar.gz riaps-bbbruntime
        '''
      }
    }
    stage('Deploy') {
      when { buildingTag() }
      steps {
        // Install github-release cli tool to build directory
        sh 'GOPATH=$WORKSPACE/go go get github.com/aktau/github-release'
        // Use GitHub OAuth token stored in 'github-token' credentials
        withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
          script {
            def user = 'riaps'
            def repo = 'riaps-integration'
            def files = ['riaps-release.tar.gz','riaps-x86runtime.tar.gz','riaps-bbbruntime.tar.gz']
            // Create release on GitHub, if it doesn't already exist
            sh "${env.WORKSPACE}/go/bin/github-release release --user ${user} --repo ${repo} --tag ${env.TAG_NAME} --name ${env.TAG_NAME} --pre-release || true"
            // Iterate over artifacts and upload them
            for(int i = 0; i < files.size(); i++){
              sh "${env.WORKSPACE}/go/bin/github-release upload -R --user ${user} --repo ${repo} --tag ${env.TAG_NAME} --name ${files[i]} --file ${files[i]}"
            }
          }
        }
      }
    }
  }
  post {
    success {
      archiveArtifacts artifacts: '*.tar.gz', fingerprint: true
    }
  }
}
