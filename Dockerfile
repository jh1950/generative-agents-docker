FROM debian:bookworm-slim

LABEL maintainer="rlawnsgl191@gmail.com"

ARG VERSION="unknown"
ENV IMAGE_VERSION=$VERSION \
    DATA_DIR="/data" \
    PYENV_ROOT="/pyenv" \
    PYENV_VERSIONS_SAVE_ROOT="pyenv-versions" \
    USER="user"
ENV TZ="UTC" \
    PUID=1000 \
    PGID=1000 \
    PYENV_AUTO_UPDATE=true \
    SERVER_INSTALL_URL="https://github.com/joonspk-research/generative_agents" \
    SERVER_AUTO_UPDATE=false \
    SERVER_PYTHON_VERSION="3.9.12" \
    SERVER_REQS_TXT="requirements.txt" \
    FRONTEND_ROOT="environment/frontend_server" \
    FRONTEND_PYTHON_VERSION="" \
    FRONTEND_REQS_TXT="requirements.txt" \
    FRONTEND_SETTINGS_PY="auto" \
    FRONTEND_ALLOWED_HOSTS="" \
    FRONTEND_TIME_ZONE="TZ" \
    BACKEND_ROOT="reverie/backend_server" \
    BACKEND_PYTHON_VERSION="" \
    BACKEND_REQS_TXT="requirements.txt" \
    BACKEND_CUSTOM_UTILS_PY=false
ENV PATH="$PYENV_ROOT/bin:$PATH" \
    REPO_URL="unused" \
    ALLOWED_HOSTS="unused"



SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN apt-get update -y \
 && apt-get install --no-install-recommends --no-install-suggests -y \
    jq git curl procps \
    libffi-dev build-essential \
    libfreetype6-dev ca-certificates \
    # pyenv dependency
    zlib1g-dev libffi-dev \
    libbz2-dev libncurses5-dev \
    libreadline-dev libssl-dev \
    libsqlite3-dev liblzma-dev \
 && useradd -ms /bin/bash "$USER" \
 && curl -sfSL https://pyenv.run | bash \
 && pyenv update \
 && echo -e "eval \"\$(pyenv init -)\"\neval \"\$(pyenv virtualenv-init -)\"" >> "/home/$USER/.bashrc" \
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
  && chown -R "$USER":"$USER" /scripts
 
 
 
 WORKDIR /scripts
 
 HEALTHCHECK \
     --timeout=5s \
     --start-period=5m \
     --retries=1 \
     CMD pgrep -f "manage.py" > /dev/null || exit 1
 
 ENTRYPOINT ["/scripts/entrypoint.sh"]
 