FROM ubuntu:18.04

LABEL maintainer Alexander Merck <alexander.t.merck@gmail.com>
LABEL name "uhp"
LABEL version "0.1"
LABEL release "1"
LABEL summary "UHP HoneyPot Container"
LABEL description "Universal Honey Pot is a medium interaction honeypot that allows defenders to quickly implement line-based TCP protocols with a simple JSON configuration."
LABEL authoritative-source-url "https://github.com/CommunityHoneyNetwork/uhp"
LABEL changelog-url "https://github.com/CommunityHoneyNetwork/uhp/commits/master"

# Set DOCKER var - used by UHP init to determine logging
ENV DOCKER "yes"
ENV playbook "uhp.yml"

RUN apt-get update \
    && apt-get install -y ansible python-apt


RUN echo "localhost ansible_connection=local" >> /etc/ansible/hosts
ADD . /opt/
RUN ansible-playbook /opt/${playbook}

ENTRYPOINT ["/usr/bin/runsvdir", "-P", "/etc/service"]