FROM ubuntu

ENV VNC_SCREEN_SIZE 1024x768

COPY copyables /

RUN apt update \
	&& apt install -y --no-install-recommends \
	ca-certificates \
	gdebi \
	gnupg2 \
	fonts-noto-cjk \
	pulseaudio \
	supervisor \
	x11vnc \
	fluxbox \
	eterm \
	xz-utils

RUN apt install curl -y --no-install-recommends \
	&& curl -o /tmp/linux_signing_key.pub https://dl.google.com/linux/linux_signing_key.pub \
	&& curl -o /tmp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
	&& curl -o /tmp/chrome-remote-desktop_current_amd64.deb https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb \
	&& apt remove curl -y \
	&& apt-key add /tmp/linux_signing_key.pub \
	&& apt install -y --no-install-recommends /tmp/chrome-remote-desktop_current_amd64.deb \
	&& apt-get clean \
	&& rm -rf /var/cache/* /var/log/apt/* /var/lib/apt/lists/* /tmp/*

RUN useradd -m -G chrome-remote-desktop,pulse-access chrome \
	&& usermod -s /bin/bash chrome \
	&& mkdir -p /home/chrome/.fluxbox \
	&& echo ' \n\
		session.screen0.toolbar.visible:        false\n\
		session.screen0.fullMaximization:       true\n\
		session.screen0.maxDisableResize:       true\n\
		session.screen0.maxDisableMove: true\n\
		session.screen0.defaultDeco:    NONE\n\
	' >> /home/chrome/.fluxbox/init \
	&& chown -R chrome:chrome /home/chrome/.config /home/chrome/.fluxbox

VOLUME ["/home/chrome"]

EXPOSE 5900

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
