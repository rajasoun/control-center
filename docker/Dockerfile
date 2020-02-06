FROM cytopia/ansible:latest-tools

RUN set -eux \
    && apk add sshpass \
    && pip3 install netaddr \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*


