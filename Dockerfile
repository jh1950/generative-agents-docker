FROM python:3.9.12-slim-bullseye

LABEL maintainer="rlawnsgl191@gmail.com"

ARG VERSION="unknown"
ENV TZ="UTC" \
    PUID=1000 \
    PGID=1000 \
    DATA_DIR="/data" \
    REPO_URL="https://github.com/joonspk-research/generative_agents" \
    AUTO_UPDATE=false \
    REQUIREMENTS="requirements.txt" \
    FRONTEND_ROOT="environment/frontend_server" \
    CONFIG_FILE="" \
    SYNC_TZ=true \
    ALLOWED_HOSTS="" \
    BACKEND_ROOT="reverie/backend_server" \
    CUSTOM_UTILS=false \
    IMAGE_VERSION=$VERSION



# hadolint ignore=DL3008
RUN apt-get update -y \
 && apt-get install --no-install-recommends --no-install-suggests -y \
    jq \
    git \
    curl \
    procps \
    libffi-dev \
    build-essential \
    libfreetype6-dev \
    ca-certificates \
 && useradd -ms /bin/bash user \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY ./scripts /scripts
RUN chmod 755 /scripts/*.sh \
 && for file in shell venv django-shell; do \
        cp /scripts/connect-copy.sh /usr/local/bin/"$file"; \
    done \
 && for file in backend reverie; do \
        cp /scripts/backend.sh /usr/local/bin/"$file"; \
    done \
 && rm /scripts/connect-copy.sh /scripts/backend.sh \
 && chown -R user:user /scripts



WORKDIR /scripts

HEALTHCHECK \
    --timeout=5s \
    --start-period=5m \
    --retries=1 \
    CMD pgrep -f "manage.py" > /dev/null || exit 1

ENTRYPOINT ["/scripts/entrypoint.sh"]
