# Savane common
apt-get --assume-yes install libmailtools-perl libdbd-mysql-perl \
  libxml-writer-perl libfile-find-rule-perl libterm-readkey-perl \
  libdate-calc-perl libstring-random-perl
# Savannah changes:
apt-get --assume-yes install libipc-run-perl
mkdir -m 755 /var/cache/savane
mkdir -m 755 /var/lock/savane

cd /usr/src
apt-get --assume-yes install make
cd savane
# avoid dealing with po files, if only using backend
#mv po/Makefile po/Makefile.copy1
#echo "install:" > po/Makefile
make
# avoid installing default crontab
if [ ! -e /etc/cron.d/savane ]; then
    echo "# Avoid using the default Savane file on make install" > /etc/cron.d/savane
fi
make install

# Locales: need de_DE.UTF-8 fr_FR.UTF-8 it_IT.UTF-8 ja_JP.UTF-8
#   pt_PT.UTF-8 ru_RU.UTF-8 sv_SE.UTF-8 en_US.UTF-8 ca_ES.UTF-8
#   es_ES.UTF-8
# Using the 2011-new "locales-all" facility
apt-get --assume-yes install locales-all

# file: /etc/membersh-conf.pl
# file: /etc/savane/savane.conf.pl
# file: /etc/cron.d/sv_*

# Allow frontend to check for compromised SSH keys ('ssh-vulnkey')
apt-get install openssh-client openssh-blacklist
