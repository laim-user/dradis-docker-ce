FROM ruby:2.4.1-slim

LABEL supported_version_dradis="3.18.0"

ENV RAILS_ENV=production \
    REDIS_URL="redis://dradis-redis:6379/1" \
    APT_ARGS="-y --no-install-recommends --no-upgrade -o Dpkg::Options::=--force-confnew" \
    BUNDLER_VERSION=2.1.4

# Copy ENTRYPOINT script and production config
COPY docker-entrypoint.sh production.rb /

RUN apt-get update && \
# Install requirements
    DEBIAN_FRONTEND=noninteractive \
    apt-get install $APT_ARGS \
      gcc \
      git \
      g++ \
      build-essential \
      libsqlite3-dev \
      make \
      nodejs \
      libmysqlclient-dev \
      wget && \
      cd /opt && \
    git clone https://github.com/dradis/dradis-ce.git --branch=v3.18.0 && \
    cd dradis-ce && \
    gem install bundler -v 2.1.4 && \
    cp /production.rb /opt/dradis-ce/config/environments/production.rb && \
  # run setup
    ruby bin/setup && \
    bundle exec rake assets:precompile && \
  # change dbdata path
    sed -i 's@database:\s*db@database: /dbdata@' /opt/dradis-ce/config/database.yml && \
  # Entrypoint:
    chmod +x /docker-entrypoint.sh && \
  # Create dradis user:
    groupadd -r dradis-ce && \
    useradd -r -g dradis-ce -d /opt/dradis-ce dradis-ce && \
    mkdir -p /dbdata /opt/dradis-ce/templates /opt/dradis-ce/attachments && \
    chown -R dradis-ce:dradis-ce /opt/dradis-ce/ /dbdata/ && \
    mv templates templates_orig && \
  # Clean up:
    apt-get remove -y --purge \
      gcc \
      g++ \
      build-essential \
      libsqlite3-dev \
      make \
      libmysqlclient-dev \
      wget && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install $APT_ARGS \
      libsqlite3-0  \
      libmysqlclient18 && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get autoremove -y && \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* && \
    rm -f /dbdata/* /production.rb

WORKDIR /opt/dradis-ce

VOLUME /dbdata
VOLUME /opt/dradis-ce/templates
VOLUME /opt/dradis-ce/attachments

EXPOSE 3000

ENTRYPOINT ["/docker-entrypoint.sh"]
