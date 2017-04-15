FROM base/archlinux

ENV RAILS_ENV=production \
    PACMAN_ARGS="--noconfirm"

# Copy ENTRYPOINT script
ADD docker-entrypoint.sh /entrypoint.sh
ADD rb23_patch.patch /rb23_patch.patch

RUN pacman -Syy $PACMAN_ARGS && \
# Install requirements
    pacman -S $PACMAN_ARGS \
      base-devel \
      ruby2.3 \
      ruby2.3-bundler \
      git \
      sqlite3 \
      nodejs \
      libmariadbclient \
      wget && \
# Install Dradis
    cd /opt && \
    git clone https://github.com/dradis/dradis-ce.git && \
    cd dradis-ce && \
    patch -p1 -i /rb23_patch.patch && \
    bundle-2.3 install --path vendor/bundle && \
    ruby-2.3 bin/setup && \
    bundle-2.3 exec rake assets:precompile && \
# Entrypoint:
    chmod +x /entrypoint.sh && \
# Create dradis user:
    groupadd -r dradis-ce && \
    useradd -r -g dradis-ce -d /opt/dradis-ce dradis-ce && \
    mkdir -p /dbdata && \
    chown -R dradis-ce:dradis-ce /opt/dradis-ce/ /dbdata/ && \
# Clean up:
    yes | pacman -Scc && \
    rm -f /dbdata/production.sqlite3

WORKDIR /opt/dradis-ce

VOLUME /dbdata

EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]
