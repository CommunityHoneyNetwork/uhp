FROM ubuntu:18.04

LABEL maintainer="Team Stingar <team-stingar@duke.edu>"
LABEL name "uhp"
LABEL version="1.9.1"
LABEL release "1"
LABEL summary="UHP HoneyPot Container"
LABEL description="Universal Honey Pot is a medium interaction honeypot that allows defenders to quickly implement line-based TCP protocols with a simple JSON configuration."
LABEL authoritative-source-url="https://github.com/CommunityHoneyNetwork/uhp"
LABEL changelog-url="https://github.com/CommunityHoneyNetwork/uhp/commits/master"

# Set DOCKER var - used by UHP init to determine logging
ENV DOCKER "yes"
ENV UHP_USER "uhp"
ENV DEBIAN_FRONTEND "noninteractive"

RUN useradd uhp

# hadolint ignore=DL3008,DL3005
RUN apt-get update \
    && apt-get install --no-install-recommends -y ansible python-apt \
    && apt-get install --no-install-recommends -y git jq python3-minimal python3-pip authbind curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /code /etc/uhp
RUN chown ${UHP_USER} /etc/uhp
COPY configs /code/configs
COPY tagging.py /code
COPY entrypoint.sh /code
COPY requirements.txt /code
COPY logging.cfg.template /code
RUN chmod +x /code/entrypoint.sh

RUN python3 -m pip install --upgrade pip setuptools wheel \
  && python3 -m pip install -r /code/requirements.txt

RUN cd /opt && \
    git clone --branch 1.1.1 https://github.com/MattCarothers/uhp && \
    chown -R uhp:uhp /opt/uhp

USER ${UHP_USER}
ENTRYPOINT ["/code/entrypoint.sh"]
