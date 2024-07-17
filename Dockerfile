FROM python:3.9.12-slim-bullseye

LABEL maintainer="rlawnsgl191@gmail.com"

RUN apt-get update -y \
 && apt-get install --no-install-recommends --no-install-suggests -y \
    curl=7.74.0-1.3+deb11u12 \
    git=1:2.30.2-1+deb11u2 \
    procps=2:3.3.17-5 \
    libffi-dev=3.3-6 \
    build-essential=12.9 \
    libfreetype6-dev=2.10.4+dfsg-1+deb11u1 \
    jq=1.6-2.1 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && useradd -ms /bin/bash user

COPY --chmod=755 ./scripts /scripts
RUN chown -R user:user /scripts

WORKDIR /scripts

ENV PUID=1000 \
    PGID=1000 \
    AUTO_UPDATE=false \
    ALLOWED_HOSTS=""

HEALTHCHECK \
    --timeout=5s \
    --start-period=5m \
    --retries=1 \
    CMD pgrep -f "manage.py" > /dev/null || exit 1

ENTRYPOINT ["/scripts/entrypoint.sh"]
