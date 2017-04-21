from fabric.api import run, env, put, sudo, get, parallel, hosts
from fabric.contrib.files import exists, append

env.hosts = ['192.168.1.102']
env.password = 'temppwd'
env.user = 'ubuntu'
env.sudo_password = 'temppwd'

def transfer_full_installfiles():
    localFilePath='/home/riaps/riaps-integration/'
    nodePutPath = '/home/ubuntu/install_files/'
    bbb_info = 'scripts/bbb/'
    version_info = 'version.sh'
    security_info = 'scripts/setup.conf'
    security_key = 'scripts/id_rsa_riaps_global'
    git_oauth = 'scripts/github_oauth'
    pkg_installfile = 'scripts/install_integration.sh'

    run('mkdir -p ' + nodePutPath + bbb_info)
    put(localFilePath + version_info, nodePutPath + version_info)
    put(localFilePath + security_info, nodePutPath + security_info)
    put(localFilePath + security_key, nodePutPath + security_key)
    put(localFilePath + security_key + '.pub', nodePutPath + security_key + '.pub')
    put(localFilePath + git_oauth, nodePutPath + git_oauth)
    put(localFilePath + pkg_installfile, nodePutPath + pkg_installfile)
    run('chmod 774 ' + nodePutPath + pkg_installfile)
    put(localFilePath + bbb_info, nodePutPath + 'scripts')
    transfer_debpkgs()


def transfer_debpkgs():
    localFilePath='/home/riaps/riaps-integration/scripts/'
    nodePutPath = '/home/ubuntu/install_files/scripts/'
    deb_pkgs = 'riaps-release.tar.gz'

    run('mkdir -p ' + nodePutPath)
    put(localFilePath + deb_pkgs, nodePutPath + deb_pkgs)
    run('tar -xzvf ' + nodePutPath + deb_pkgs + ' -C ' + nodePutPath)
    run('rm ' + nodePutPath + deb_pkgs)


def bbb_full_install():
    nodePutPath = '/home/ubuntu/install_files/'
    bbb_installfile = 'riaps_bbb_base_setup.sh'

    transfer_full_installfiles()
    run('chmod 774 ' + nodePutPath + bbb_installfile)
    run('sudo .' + nodePutPath + bbb_installfile)

def bbb_install_update():
    nodePutPath = '/home/ubuntu/install_files/'
    bbb_updatefile = 'install_integration.sh'

    transfer_debpkgs()
    run('sudo .' + nodePutPath + bbb_updatefile)
