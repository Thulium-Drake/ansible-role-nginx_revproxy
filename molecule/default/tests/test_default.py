import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_nginx_config(host):
    nginx_conf = host.file("/etc/nginx/sites-enabled/revproxy.lab.conf")
    assert nginx_conf.is_file


def test_nginx_url(host):
    assert host.ansible('uri', 'return_content=true \
        url=https://revproxy.lab validate_certs=false',
                        check=False)['content'] == 'it_works'
