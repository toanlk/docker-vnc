FROM ubuntu:22.04

# built-in packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y \
        supervisor sudo net-tools wget \
        dbus-x11 x11-utils alsa-utils \
        mesa-utils libgl1-mesa-dri \
        python3.10 python3.10-venv python3-pip \
        iputils-ping htop \
    && apt-get install -y \
        xvfb x11vnc \
    && apt-get install -y lxqt openbox

RUN apt-get install -y tini

#================
# Install Chrome
#================
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN dpkg -i google-chrome-stable_current_amd64.deb || true && \
    apt-get update && \
    apt-get install -y -f
RUN rm ./google-chrome-stable_current_amd64.deb

RUN apt-get update \
    && apt-get autoclean -y \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

ADD startup.sh /
ADD supervisord.conf /etc/supervisor/conf.d/
ADD xvfb.sh /usr/local/bin/

#=====================
# Set up python stuff
#=====================
RUN pip3 install --upgrade pip setuptools wheel

WORKDIR /app
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

#=======================
# Download chromedriver
#=======================
RUN seleniumbase get chromedriver --path

ENV SHELL=/bin/bash
ENV PYTHONPATH=/app

RUN chmod +x /startup.sh \
    && chmod +x /usr/local/bin/xvfb.sh

ENTRYPOINT ["/startup.sh"]