# An incomplete base Docker image for running JupyterHub
#
# Add your configuration to create a complete derivative Docker image.
#
# Include your configuration settings by starting with one of two options:
#
# Option 1:
#
# FROM jupyterhub/jupyterhub:latest
#
# And put your configuration file jupyterhub_config.py in /srv/jupyterhub/jupyterhub_config.py.
#
# Option 2:
#
# Or you can create your jupyterhub config and database on the host machine, and mount it with:
#
# docker run -v $PWD:/srv/jupyterhub -t jupyterhub/jupyterhub
#
# NOTE
# If you base on jupyterhub/jupyterhub-onbuild
# your jupyterhub_config.py will be added automatically
# from your docker directory.

FROM ubuntu:18.04
LABEL maintainer="Alexander von Birgelen <avonbirgelen@phoenixcontact.com>"

ENV container docker

# install nodejs, utf8 locale, set CDN because default httpredir is unreliable
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install wget git bzip2 && \
    apt-get -y install nano && \
    apt-get -y install systemd && \
    apt-get purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
ENV LANG C.UTF-8

RUN systemctl set-default multi-user.target

# install Python + NodeJS with conda + jupyter-notebook
RUN wget -q https://repo.continuum.io/miniconda/Miniconda3-4.5.1-Linux-x86_64.sh -O /tmp/miniconda.sh  && \
    echo '0c28787e3126238df24c5d4858bd0744 */tmp/miniconda.sh' | md5sum -c - && \
    bash /tmp/miniconda.sh -f -b -p /opt/conda && \
    /opt/conda/bin/conda install --yes -c conda-forge \
      python=3.6 sqlalchemy tornado jinja2 traitlets requests pip pycurl \
      nodejs configurable-http-proxy jupyter && \
    /opt/conda/bin/pip install --upgrade pip && \
    /opt/conda/bin/pip install jupyterhub-systemdspawner jupyterhub-simplespawner dockerspawner && \
    rm /tmp/miniconda.sh
ENV PATH=/opt/conda/bin:$PATH

ADD . /src/jupyterhub
WORKDIR /src/jupyterhub

RUN pip install . && \
    rm -rf $PWD ~/.cache ~/.npm

RUN mkdir -p /srv/jupyterhub/
WORKDIR /srv/jupyterhub/
EXPOSE 8000

RUN ln -s /usr/local/bin/configurable-http-proxy /usr/bin/configurable-http-proxy

LABEL org.jupyter.service="jupyterhub"

ADD ./proficloud/jupyterhub_config.py /srv/jupyterhub/jupyterhub_config.py
ADD ./proficloud/dictauth.py /srv/jupyterhub/dictauth.py

ADD ./proficloud/jupyterhub.service /etc/systemd/system/jupyterhub.service

ADD ./proficloud/jupyterhub.sh /srv/jupyterhub/jupyterhub.sh
RUN chmod +x /srv/jupyterhub/jupyterhub.sh

RUN systemctl enable jupyterhub.service

VOLUME ["/sys/fs/cgroup"]

CMD ["/sbin/init"]
