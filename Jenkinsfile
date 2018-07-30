pipeline {
  agent any
  stages {
    stage('Fetch packages') {
      steps {
        withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_OAUTH_TOKEN')]) {
          sh '''#!/bin/bash
            wget https://github.com/gruntwork-io/fetch/releases/download/v0.1.1/fetch_linux_amd64
            chmod +x fetch_linux_amd64
            source version.sh
            ./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-externals/" --tag="$externalsversion" --release-asset="riaps-externals-armhf.deb" .
            ./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-externals/" --tag=$externalsversion --release-asset="riaps-externals-amd64.deb" .
            ./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-core" --tag=$coreversion --release-asset="riaps-core-amd64.deb" .
            ./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-core" --tag=$coreversion --release-asset="riaps-core-armhf.deb" .
            ./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-pycom" --tag=$pycomversion --release-asset="riaps-pycom-amd64.deb" .
            ./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-pycom" --tag=$pycomversion --release-asset="riaps-pycom-armhf.deb" .
            ./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-pycom" --tag=$pycomversion --release-asset="riaps-systemd-armhf.deb" .
            ./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-pycom" --tag=$pycomversion --release-asset="riaps-systemd-amd64.deb" .
            ./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-timesync" --tag=$timesyncversion --release-asset="riaps-timesync-amd64.deb" .
            ./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-timesync" --tag=$timesyncversion --release-asset="riaps-timesync-armhf.deb" .
          '''
        }
      }
    }
    stage('Package') {
      steps {
        sh '''#!/bin/bash
          mkdir riaps-release
          cp riapsdsmlplugin.tar.gz riaps-externals-armhf.deb riaps-externals-amd64.deb riaps-core-amd64.deb riaps-core-armhf.deb riaps-pycom-amd64.deb riaps-pycom-armhf.deb riaps-systemd-amd64.deb riaps-systemd-armhf.deb riaps-timesync-amd64.deb riaps-timesync-armhf.deb riaps-release/.
          echo "externalsversion=$externalsversion" >> riaps-release/manifest.txt
          echo "coreversion=$coreversion" >> riaps-release/manifest.txt
          echo "pycomversion=$pycomversion" >> riaps-release/manifest.txt
          echo "timesyncversion=$timesyncversion" >> riaps-release/manifest.txt
          echo "riapsdsmlversion=$riapsdsmlversion" >> riaps-release/manifest.txt
          tar cvzf riaps-release.tar.gz riaps-release
          cp version.sh riaps-x86runtime/.
          tar cvzf riaps-x86runtime.tar.gz riaps-x86runtime
          cp version.sh riaps-bbbruntime/.
          tar cvzf riaps-bbbruntime.tar.gz riaps-bbbruntime
        '''
      }
    }
    stage('Archive artifacts') {
      steps {
        fileExists 'riaps-release.tar.gz'
        archiveArtifacts(artifacts: 'riaps-release.tar.gz', onlyIfSuccessful: true, fingerprint: true)
        fileExists 'priaps-x86runtime.tar.gz'
        archiveArtifacts(artifacts: 'riaps-x86runtime.tar.gz', onlyIfSuccessful: true, fingerprint: true)
        fileExists 'priaps-bbbruntime.tar.gz'
        archiveArtifacts(artifacts: 'riaps-bbbruntime.tar.gz', onlyIfSuccessful: true, fingerprint: true)
      }
    }
  }
}
