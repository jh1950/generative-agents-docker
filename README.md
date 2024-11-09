# [Generative Agents](https://github.com/joonspk-research/generative_agents) 전용 컨테이너

> [!NOTE]
> 이 소스코드는 [MIT 라이선스](https://github.com/jh1950/generative-agents-docker/blob/main/LICENSE)를 따르지만,
> [Generative Agents](https://github.com/jh1950/generative_agents)는
> [아파치 라이선스](https://www.apache.org/licenses/LICENSE-2.0.txt)를 따릅니다.

[![License](https://img.shields.io/github/license/jh1950/generative-agents-docker?label=License)](https://github.com/jh1950/generative-agents-docker/blob/main/LICENSE)
[![Include License](https://img.shields.io/github/license/joonspk-research/generative_agents?&label=Include)](https://www.apache.org/licenses/LICENSE-2.0.txt)

[![GitHub](https://img.shields.io/badge/GitHub-Source-blue?logo=github)](https://github.com/jh1950/generative-agents-docker)
[![Latest Version](https://img.shields.io/github/v/release/jh1950/generative-agents-docker?label=Latest)](https://github.com/jh1950/generative-agents-docker/releases)
[![Source Size](https://img.shields.io/github/repo-size/jh1950/generative-agents-docker?label=Source)](https://github.com/jh1950/generative-agents-docker)
[![Image Size](https://img.shields.io/docker/image-size/jh1950/generative-agents-docker?label=Image)](https://hub.docker.com/r/jh1950/generative-agents-docker/tags)

[![Publish](https://github.com/jh1950/generative-agents-docker/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/jh1950/generative-agents-docker/actions/workflows/docker-publish.yml)
[![Linting](https://github.com/jh1950/generative-agents-docker/actions/workflows/linting.yml/badge.svg)](https://github.com/jh1950/generative-agents-docker/actions/workflows/linting.yml)

[![Docker Hub](https://img.shields.io/badge/Docker-Hub-blue?logo=docker)](https://hub.docker.com/r/jh1950/generative-agents-docker)
[![GHCR](https://img.shields.io/badge/GHCR-Package-blue?logo=github)](https://github.com/jh1950/generative-agents-docker/pkgs/container/generative-agents-docker)

[jh1950/generative_agents](https://github.com/jh1950/generative_agents)
전용으로 만들기 시작했으나, v0.4.0 부터 원본 프로젝트인
[joonspk-research/generative_agents](https://github.com/joonspk-research/generative_agents)를
포함하여 다른 포크된 버전도 사용할 수 있습니다.



## 이미지 설치

아래 명령어를 실행합니다.

```bash
docker pull jh1950/generative-agents-docker:latest
```



## 컨테이너 실행

컨테이너를 실행하려면 먼저 임의의 디렉토리를 생성한 후 그 안에
[docker-compose.yml](https://github.com/jh1950/generative-agents-docker/blob/main/docker-compose.yml)
파일을 작성하고, 필요한 경우 [환경 변수](#환경-변수)를 수정합니다.

그 후 해당 파일이 위치한 곳에서 아래 명령어를 실행합니다.

```bash
docker compose up -d
```



## 컨테이너 중지

실행된 컨테이너는 시스템이 부팅될 때마다 자동으로 컨테이너가 다시 실행됩니다.

컨테이너를 중지하려면 아래 명령어를 실행합니다.

```bash
docker compose down
```

또는 `docker-compose.yml` 파일의
[restart](https://docs.docker.com/engine/containers/start-containers-automatically/#use-a-restart-policy)
값을 수정하여 설정을 변경할 수 있습니다.



## 컨테이너 로그

> [!TIP]
> 실시간으로 로그를 확인하려면 마지막에 `-f`를 추가합니다.

컨테이너 및 프론트엔드 로그를 보려면 아래 명령어를 실행합니다.

```bash
docker logs generative_agents
```



## 컨테이너 접속

> [!TIP]
> 접속을 종료하려면 아무것도 입력하지 않은 상태에서 `Ctrl+d`를 누릅니다.

컨테이너에 연결하여 컨테이너 내 파이썬 환경을 그대로 사용할 수 있습니다.

### Bash

가상환경이 적용된 쉘에 연결됩니다.

```bash
docker exec -it --user user generative_agents bash # v0.1.0 ~
# or docker exec -it generative_agents shell # v0.4.0 ~
```

### Python

Interactive 모드로, 프론트엔드인 Django 서버와 연결됩니다.

```bash
docker exec -it generative_agents <venv|django-shell> # v0.4.0 ~
```



## 환경 변수

> [!NOTE]
> _**이탤릭체**_: 기본값 사용 권장

[docker-compose.yml](https://github.com/jh1950/generative-agents-docker/blob/main/docker-compose.yml),
[.env](https://github.com/jh1950/generative-agents-docker/blob/main/.env.example)
파일에서 설정 가능한 환경 변수 목록입니다.

| 변수명                                          | 설명                                                                       | 기본값                                                  | 설정 가능한 값                                                                                   | 추가된 버전 |
|-------------------------------------------------|----------------------------------------------------------------------------|---------------------------------------------------------|--------------------------------------------------------------------------------------------------|-------------|
| TZ                                              | 컨테이너 타임존                                                            | `UTC`                                                   | [TZ Identifiers(식별자)](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) 참고      | 0.1.0       |
| PUID                                            | 서버를 실행할 유저의 UID (`id -u` 명령어로 확인 가능)                      | `1000`                                                  | 1~                                                                                               | 0.1.0       |
| PGID                                            | 서버를 실행할 그룹의 GID (`id -g` 명령어로 확인 가능)                      | `1000`                                                  | 1~                                                                                               | 0.1.0       |
| DOCKER_VERSION_CHECK                            | 도커 이미지 최신버전 체크                                                  | `true`                                                  | boolean                                                                                          | 1.2.0       |
| PYENV_AUTO_UPDATE                               | pyenv 버전 자동 업데이트                                                   | `true`                                                  | boolean                                                                                          | 1.0.0       |
| SERVER_INSTALL_URL\*                            | 설치할 서버의 GitHub URL                                                   | `https://github.com/joonspk-research/generative_agents` | 원본 프로젝트 및 포크된 버전의 URL                                                               | 1.0.0       |
| _**[SERVER_AUTO_UPDATE](#server_auto_update)**_ | 서버 실행 전 서버 업데이트 확인 및 진행                                    | `false`                                                 | boolean                                                                                          | 1.0.0       |
| SERVER_PYTHON_AWAIT_INSTALL\*\*                 | 서버 파이썬 설치가 완료될 때까지 대기                                      | `false`                                                 | boolean                                                                                          | 1.2.0       |
| SERVER_PYTHON_VERSION\*                         | 설치할 파이썬 버전                                                         | `3.9.12`                                                | [pyenv](https://github.com/pyenv/pyenv/tree/master/plugins/python-build/share/python-build) 참고 | 1.1.0       |
| SERVER_REQS_TXT\*                               | `/data` 디렉토리 내 `requirements.txt` 파일 경로                           | `requirements.txt`                                      | `path`, `./to`, `/file`                                                                          | 1.0.0       |
| FRONTEND_ROOT                                   | `/data` 디렉토리 내 프론트엔드 디렉토리 경로                               | `environment/frontend_server`                           | `path`, `./to`, `/dir`                                                                           | 0.4.0       |
| FRONTEND_ENABLED                                | 프론트엔드 실행 여부                                                       | `true`                                                  | boolean                                                                                          | 1.2.0       |
| FRONTEND_PYTHON_AWAIT_INSTALL\*\*               | 프론트엔드 전용 파이썬 설치가 완료될 때까지 대기                           | `false`                                                 | boolean                                                                                          | 1.2.0       |
| FRONTEND_PYTHON_VERSION                         | 프론트엔드 전용 파이썬 버전                                                | -                                                       | `PYTHON_VERSION` 참고                                                                            | 1.1.0       |
| FRONTEND_REQS_TXT\*                             | `FRONTEND_ROOT` 디렉토리 내 `requirements.txt` 파일 경로                   | `requirements.txt`                                      | `path`, `./to`, `/file`                                                                          | 1.1.0       |
| FRONTEND_SETTINGS_PY\*                          | `FRONTEND_ROOT` 디렉토리 내 프론트엔드 설정 파일 경로                      | any1/any2.py, any1/any2/local.py인 경우 자동 탐지       | `path`, `./to`, `/file`                                                                          | 1.0.0       |
| FRONTEND_ALLOWED_HOSTS\*                        | 프론트엔드 접속 허용 IP를 설정 (쉼표로 구분하여 여러 값 설정 가능)         | `container`([컨테이너 내부 IP](#웹-접속))               | `IP`, `IP, Domain, ...`, `container`                                                             | 1.0.0       |
| FRONTEND_TIME_ZONE\*                            | 프론트엔드 타임존 설정                                                     | `TZ` 값 사용                                            | `TZ` 참고                                                                                        | 1.0.0       |
| BACKEND_ROOT                                    | `/data` 디렉토리 내 백엔드 디렉토리 경로                                   | `reverie/backend_server`                                | `path`, `./to`, `/dir`                                                                           | 0.5.0       |
| BACKEND_PYTHON_AWAIT_INSTALL\*\*                | 백엔드 전용 파이썬 설치가 완료될 때까지 대기                               | `false`                                                 | boolean                                                                                          | 1.2.0       |
| BACKEND_PYTHON_VERSION                          | 백엔드 전용 파이썬 버전                                                    | -                                                       | `PYTHON_VERSION` 참고                                                                            | 1.1.0       |
| BACKEND_REQS_TXT\*                              | `BACKEND_ROOT` 디렉토리 내 `requirements.txt` 파일 경로                    | `requirements.txt`                                      | `path`, `./to`, `/file`                                                                          | 1.1.0       |
| BACKEND_CUSTOM_UTILS_PY                         | 커스텀 `utils.py` 파일 사용 (`BACKEND_ROOT` 디렉토리 내 직접 생성)         | `false`                                                 | boolean                                                                                          | 1.0.0       |
| OPENAI_API_KEY                                  | OpenAI API Key (`BACKEND_CUSTOM_UTILS_PY` 값이 `false`일 경우 사용)        | -                                                       | `string`                                                                                         | 0.5.0       |
| OPENAI_API_OWNER                                | OpenAI API Key 소유자 (`BACKEND_CUSTOM_UTILS_PY` 값이 `false`일 경우 사용) | -                                                       | `string`                                                                                         | 0.5.0       |

\* 빈값 설정 시 관련 기능이 진행되지 않습니다.
\*\* 여러 컨테이너에서 같은 볼륨을 사용하는 경우 활용 가능합니다. (`*_PYTHON_VERSION` 값이 설정된 경우에만 적용)

<!-- markdownlint-disable-next-line -->
<details><summary>제거된 변수 목록</summary>

| 변수명         | 사용 가능한 버전 | 대체된 변수명           |
|----------------|------------------|-------------------------|
| ALLOWED_HOSTS  | 0.1.0 ~ 0.6.1    | FRONTEND_ALLOWED_HOSTS  |
| AUTO_UPDATE    | 0.2.0 ~ 0.6.1    | SERVER_AUTO_UPDATE      |
| CONFIG_FILE    | 0.2.0 ~ 0.6.1    | FRONTEND_SETTINGS_PY    |
| SYNC_TZ        | 0.3.1 ~ 0.6.1    | FRONTEND_TIME_ZONE      |
| REPO_URL       | 0.4.0 ~ 0.6.1    | SERVER_INSTALL_URL      |
| CUSTOM_UTILS   | 0.5.0 ~ 0.6.1    | BACKEND_CUSTOM_UTILS_PY |
| REQUIREMENTS   | 0.6.0 ~ 0.6.1    | SERVER_REQS_TXT         |
| PYTHON_VERSION | 1.0.0 ~ 1.0.0    | SERVER_PYTHON_VERSION   |

</details>

### SERVER_AUTO_UPDATE

> [!CAUTION]
> 버전 `0.3.1` 이하에서는 변경된 내용이 **임시저장되지 않습니다**.

환경 변수 `SERVER_AUTO_UPDATE` 값을 `true`로 사용할 경우, 업데이트 진행 시 내용이 변경된 파일들은 모두 임시 저장됩니다.

임시 저장된 내용은 아래 명령어로 복구가 가능합니다.
(별도의 **Merge** 작업이 필요할 수 있습니다.)

```bash
git stash list # stash@{0}, stash@{1} 형식의 name 확인
git stash apply name
# git stash drop name # 임시 저장 제거
# git stash clear # 임시 저장 모두 제거
```



## 웹 접속

> [!TIP]
> `docker exec generative_agents hostname -I`
> 명령어로 컨테이너 내부 IP를 확인할 수 있습니다.

만약 컨테이너 포트 연결을 `8001:8000`로 설정했다면 다음과 같은 방법으로 접속합니다.

 1. <http://localhost:8001>
 2. <http://컨테이너_내부_IP:8000>



## 백엔드 실행

```bash
docker exec -it generative_agents backend [<FORKED_SIMULATION> <NEW_SIMULATION> [OPTION...]]
```

추가 인자 입력 시 별도의 입력 프롬프트가 뜨지 않고 자동으로 진행됩니다.

단, 아래와 같이 인자는 최소 3개 이상이어야 하며, 하나의 옵션끼리 따옴표로 묶어 구분해야 합니다.

```bash
docker exec -it generative_agents backend "base_the_ville_isabella_maria_klaus" "new_name" "option 1" "option 2"
```

### 백그라운드 실행

> [!CAUTION]
> 백그라운드 실행 시 중단할 수 없습니다.
> API 사용 시 과금에 주의해 주세요.

백엔드를 백그라운드로 실행한 후 세션을 종료합니다.

```bash
docker exec -it generative_agents backend --background <FORKED_SIMULATION> <NEW_SIMULATION> [OPTION...]
```
