#holiweed Dockerfile

#Base image
FROM kalilinux/kali-rolling:latest

#Credits & Data
LABEL \
	name="holiweed" \
	author="Oscar_Cardenas <Oscar_Cardenas.1s.h3r3@gmail.com>" \
	maintainer="OscarAkaElvis <oscar.alfonso.diaz@gmail.com>" \
	description="This is a multi-use bash script for Linux systems to audit wireless networks."

#Env vars
ENV holiweed_URL="https://github.com/Oscar_Cardenas1sh3r3/holiweed.git"
ENV HASHCAT2_URL="https://github.com/Oscar_Cardenas1sh3r3/hashcat2.0.git"
ENV DEBIAN_FRONTEND="noninteractive"

#Update system
RUN apt update

#Set locales
RUN \
	apt -y install \
	locales && \
	locale-gen en_US.UTF-8 && \
	sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
	echo 'LANG="en_US.UTF-8"' > /etc/default/locale && \
	dpkg-reconfigure --frontend=noninteractive locales && \
	update-locale LANG=en_US.UTF-8

#Env vars for locales
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US:en"
ENV LC_ALL="en_US.UTF-8"

#Install holiweed essential tools
RUN \
	apt -y install \
	gawk \
	iw \
	aircrack-ng \
	xterm \
	iproute2 \
	pciutils \
	procps \
	tmux

#Install holiweed internal tools
RUN \
	apt -y install \
	ethtool \
	usbutils \
	rfkill \
	x11-utils \
	wget \
	ccze \
	x11-xserver-utils

#Install update tools
RUN \
	apt -y install \
	curl \
	git

#Install holiweed optional tools
RUN \
	apt -y install \
	crunch \
	hashcat \
	mdk3 \
	mdk4 \
	hostapd \
	lighttpd \
	iptables \
	nftables \
	ettercap-text-only \
	bettercap \
	isc-dhcp-server \
	dnsmasq \
	reaver \
	bully \
	pixiewps \
	hostapd-wpe \
	asleap \
	john \
	openssl \
	hcxtools \
	hcxdumptool \
	beef-xss \
	tshark

#Env var for display
ENV DISPLAY=":0"

#Create volume dir for external files
RUN mkdir /io
VOLUME /io

#Set workdir
WORKDIR /opt/

#holiweed install method 1 (only one method can be used, other must be commented)
#Install holiweed (Docker Hub automated build process)
RUN mkdir holiweed
COPY . /opt/holiweed

#holiweed install method 2 (only one method can be used, other must be commented)
#Install holiweed (manual image build)
#Uncomment git clone line and one of the ENV vars to select branch (master->latest, dev->beta)
#ENV BRANCH="master"
#ENV BRANCH="dev"
#RUN git clone -b ${BRANCH} ${holiweed_URL}

#Remove auto update
RUN sed -i 's|holiweed_AUTO_UPDATE=true|holiweed_AUTO_UPDATE=false|' holiweed/.holiweedrc

#Force use of iptables
RUN sed -i 's|holiweed_FORCE_IPTABLES=false|holiweed_FORCE_IPTABLES=true|' holiweed/.holiweedrc

#Make bash script files executable
RUN chmod +x holiweed/*.sh

#Downgrade Hashcat
RUN \
	git clone ${HASHCAT2_URL} && \
	cp /opt/hashcat2.0/hashcat /usr/bin/ && \
	chmod +x /usr/bin/hashcat

#Clean packages
RUN \
	apt clean && \
	apt autoclean && \
	apt autoremove -y

#Clean files
RUN \
	rm -rf /opt/holiweed/imgs > /dev/null 2>&1 && \
	rm -rf /opt/holiweed/.github > /dev/null 2>&1 && \
	rm -rf /opt/holiweed/.editorconfig > /dev/null 2>&1 && \
	rm -rf /opt/holiweed/CONTRIBUTING.md > /dev/null 2>&1 && \
	rm -rf /opt/holiweed/CODE_OF_CONDUCT.md > /dev/null 2>&1 && \
	rm -rf /opt/holiweed/pindb_checksum.txt > /dev/null 2>&1 && \
	rm -rf /opt/holiweed/Dockerfile > /dev/null 2>&1 && \
	rm -rf /opt/holiweed/binaries > /dev/null 2>&1 && \
	rm -rf /opt/hashcat2.0 > /dev/null 2>&1 && \
	rm -rf /opt/holiweed/plugins/* > /dev/null 2>&1 && \
	rm -rf /tmp/* > /dev/null 2>&1 && \
	rm -rf /var/lib/apt/lists/* > /dev/null 2>&1

#Expose BeEF control panel port
EXPOSE 3000

#Create volume for plugins
VOLUME /opt/holiweed/plugins

#Start command (launching holiweed)
CMD ["/bin/bash", "-c", "/opt/holiweed/holiweed.sh"]
