#!/bin/bash

apt-get install build-essential dkms xserver-xorg

# Manually install guest additions
# Menu: Devices > Insert Guest Additions CD image
#mount /dev/cdrom /mnt

# Automate VBox guest additions by downloading the ISO from virtualbox.org.
# An alternative method would be to manually share the directory on the host
# which actually contains VBoxGuestAdditions.iso. On a Mac that is
# /Applications/VirtualBox.app/Contents/MacOS/. Just like with the host user's
# home directory however, there's no convenient variable representing this
# location within the Shared Folders configuration.
echo "BCE: Installing Guest Additions..."
(
	V=$(dmidecode | grep vboxVer | sed -e 's/.*_//')
	ISO=VBoxGuestAdditions_${V}.iso
	ISO_URL=http://download.virtualbox.org/virtualbox/${V}/${ISO}
	wget -O /tmp/${ISO} ${ISO_URL} && \
	mount -o loop /tmp/${ISO} /mnt && \
	/mnt/VBoxLinuxAdditions.run && \
	umount /mnt
) && \
echo DONE || echo FAIL

# CRAN repo
# There is no 14.04 CRAN archive yet but R is recent enough in 14.04. We
# install a cran.list but it is disabled.
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 && \
#echo "#deb http://cran.cnr.berkeley.edu/bin/linux/ubuntu trusty/" > \
#	/etc/apt/sources.list.d/cran.list && \
# Prefer rrutter and c2d4u PPAs
add-apt-repository -y ppa:marutter/rrutter
add-apt-repository -y ppa:marutter/c2d4u

apt-get update
apt-get dist-upgrade

# apt-get installing python-gtk2-dev is much faster than pip-installing gtk2

# Packages
apt-get install git sqlite3 pandoc emacs xemacs21 default-jre default-jdk \
	r-recommended libjpeg62 \
	python-dev python-setuptools python-pip python-gtk2-dev \
	texlive{,-latex-{base,extra},-fonts-{extra,recommended},-pictures} \
	gedit{,{,-developer}-plugins,-{r,latex,source-code-browser}-plugin} \
	rabbitvcs-gedit thunar-vcs-plugin \
	google-chrome-stable firefox xpdf evince gv libreoffice \
	libyaml-dev libzmq3-dev python-software-properties \
	lightdm xfce4{,-terminal} xubuntu-default-settings

# Google Chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | \
	apt-key add -
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > \
	/etc/apt/sources.list.d/google-chrome.list

# R, RStudio
wget http://www.stat.berkeley.edu/~ryan/cloud/getrstudio && \
RSTUDIO_URL=`python getrstudio -32` && \
wget ${RSTUDIO_URL} && \
dpkg -i $(basename ${RSTUDIO_URL})

# < = requires package ; > = pulls in
# boilerpipe < default-jre default-jdk
# boilerpipe > JPype1 charade
# pyyaml < libyaml-dev
# pandas > dateutil pytz numpy
# ipython > tornado pyparsing nose backports.ssl-match-hostname 
# sphinx > Pygments docutils Jinja2 markupsafe
# scrapy > Twisted w3lib queuelib cssselect
# flask > Werkzeug itsdangerous
# ipythonblocks < ez_setup
# seaborn < patsy
# seaborn > husl moss statsmodels
# ipython notebook < pyzmq libzmq3-dev
for p in pandas matplotlib scipy rpy2 ipython sphinx scrapy distribute virtualenv apiclient BeautifulSoup boilerpipe bson cluster envoy feedparser flask geopy networkx oauth2 prettytable pygithub pymongo readline requests twitter twitter-text-py uritemplate google-api-python-client jinja facebook nltk ez_setup ipythonblocks scikits.learn sklearn-pandas patsy seaborn pyzmq markdown git+git://github.com/getpelican/pelican.git@011cd50e2e7 ghp-import; do

	pip install $p
done

# Configure desktop
update-alternatives --set x-session-manager /usr/bin/startxfce4

# Automatically login oski at boot
printf "[SeatDefaults]\nautologin-user=oski\nautologin-user-timeout=0\n" >> \
	/etc/lightdm/lightdm.conf.d/20-BCE.conf
#/usr/lib/lightdm/lightdm-set-defaults --autologin oski

# Hide boot messages
sed -i \
	-e '/GRUB_HIDDEN_TIMEOUT=/s/^#//' \
	-e '/^GRUB_CMDLINE_LINUX_DEFAULT=""/s/""/"quiet splash"/' \
	/etc/default/grub

# Enable oski to sudo without a password
adduser oski sudo
printf "%sudo\tALL=(ALL:ALL) NOPASSWD: ALL\n" > /etc/sudoers.d/nopasswd
# Enable oski to mount shared folders
adduser oski vboxsf
# Enable oski to login without a password
adduser oski nopasswdlogin

# Set a 4-space tabstop for nano
sed -i -e '/# set tabsize 8/s/.*/set tabsize 4/' /etc/nanorc

# Clean up the image before we export it
apt-get clean
(
	cd /home/oski
	rm -rf .cache Music Pictures Public Templates Videos
	# Create a convenient place on the desktop for people to mount
	# their Shared Directories.
	cd Desktop
	ln -s /media Shared
)

# Not included here:
# - configuring the xfce desktop, e.g. icons, launchers, background
################################################################################
