apt-get update
apt-get install dirmngr resolvconf -y
echo "deb http://packages.openmediavault.org/public arrakis main" > /etc/apt/sources.list.d/openmediavault.list
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 7E7A6C592EF35D13 24863F0C716B980B 8B48AD6246925553 7638D0442B90D010

export LANG=C
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none

apt-get update

sed -i "s#def remove(wr, selfref=ref(self)):#def remove(wr, selfref=ref(self), _atomic_removal=_remove_dead_weakref):#g" /usr/lib/python3.5/weakref.py

sed -i "s#_remove_dead_weakref(d, wr.key)#_atomic_removal(d, wr.key)#g" /usr/lib/python3.5/weakref.py


apt-get --yes --auto-remove --show-upgraded \
--allow-downgrades --allow-change-held-packages \
--no-install-recommends \
--option Dpkg::Options::="--force-confdef" \
--option DPkg::Options::="--force-confold" \
install postfix openmediavault -y

omv-initsystem

wget http://omv-extras.org/openmediavault-omvextrasorg_latest_all4.deb

dpkg -i openmediavault-omvextrasorg_latest_all4.deb

apt-get update


export http_proxy=http://192.168.31.136:1087;export https_proxy=http://192.168.31.136:1087;