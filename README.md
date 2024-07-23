# Generative Agents 전용 컨테이너

> [!NOTE]
> 이 소스코드는 [MIT 라이선스](https://github.com/jh1950/generative-agents-docker/blob/main/LICENSE)를 따르지만,
> [Generative Agents](https://github.com/jh1950/generative_agents)는
> [아파치 라이선스](https://www.apache.org/licenses/LICENSE-2.0.txt)를 따릅니다.

[![License](https://img.shields.io/github/license/jh1950/generative-agents-docker?label=License)](https://github.com/jh1950/generative-agents-docker/blob/main/LICENSE)
[![Include License](https://img.shields.io/github/license/jh1950/generative_agents?&label=Include)](https://www.apache.org/licenses/LICENSE-2.0.txt)

[![GitHub](https://img.shields.io/badge/GitHub-Source-blue?logo=github)](https://github.com/jh1950/generative-agents-docker)
[![Latest Version](https://img.shields.io/github/v/release/jh1950/generative-agents-docker?label=Latest)](https://github.com/jh1950/generative-agents-docker/releases)
[![Source Size](https://img.shields.io/github/repo-size/jh1950/generative-agents-docker?label=Source)](https://github.com/jh1950/generative-agents-docker)
[![Image Size](https://img.shields.io/docker/image-size/jh1950/generative-agents-docker?label=Image)](https://hub.docker.com/r/jh1950/generative-agents-docker/tags)

[![Publish](https://github.com/jh1950/generative-agents-docker/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/jh1950/generative-agents-docker/actions/workflows/docker-publish.yml)
[![Linting](https://github.com/jh1950/generative-agents-docker/actions/workflows/linting.yml/badge.svg)](https://github.com/jh1950/generative-agents-docker/actions/workflows/linting.yml)

[![Docker Hub](https://img.shields.io/badge/Docker-Hub-blue?logo=docker)](https://hub.docker.com/r/jh1950/generative-agents-docker)
[![GHCR](https://img.shields.io/badge/GHCR-Package-blue?logo=github)](https://github.com/jh1950/generative-agents-docker/pkgs/container/generative-agents-docker)

[jh1950/generative_agents](https://github.com/jh1950/generative_agents)
전용 컨테이너로 만들기 시작했으며, 현재는 원본 프로젝트인
[joonspk-research/generative_agents](https://github.com/joonspk-research/generative_agents)
와 다른 포크된 버전도 사용할 수 있습니다.


## 이미지 설치

아래 명령어를 실행합니다.

```bash
docker pull jh1950/generative-agents-docker:latest
```


## 컨테이너 실행

컨테이너를 실행하려면 먼저 임의의 폴더를 생성한 후 그 안에
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


## 컨테이너 로그

> [!TIP]
> 실시간으로 로그를 확인하려면 마지막에 `-f`를 추가합니다.

```bash
docker compose logs
# or docker logs generative_agents
```


## 컨테이너 접속

> [!TIP]
> 접속을 종료하려면 아무것도 입력하지 않은 상태에서 `Ctrl+d`를 누릅니다.

컨테이너에 연결하여 컨테이너 내 파이썬 환경을 그대로 사용할 수 있습니다.

### Bash

가상환경이 적용된 Bash

```bash
docker exec -it --user user generative_agents bash # v0.1.0 ~
# or docker exec -it generative_agents shell # v0.4.0 ~
```

### Python

Interactive 모드로, 프론트엔드인 Django 서버와 연결됩니다.

```bash
docker exec -it generative_agents venv # v0.4.0 ~
```


## 환경 변수

> [!NOTE]
>
> _**이탤릭체**_: 기본값 사용 권장

[docker-compose.yml](https://github.com/jh1950/generative-agents-docker/blob/main/docker-compose.yml),
[.env](https://github.com/jh1950/generative-agents-docker/blob/main/.env.example)
파일에서 설정 가능한 환경 변수 목록입니다.

| 변수명                            | 설명 ________________________________________                      | 기본값                                            | 설정 가능한 값                                                                              | 추가된 버전 |
|-----------------------------------|--------------------------------------------------------------------|---------------------------------------------------|---------------------------------------------------------------------------------------------|-------------|
| TZ                                | 컨테이너 타임존                                                    | `UTC`                                             | [TZ Identifiers(식별자)](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) 참고 | 0.1.0       |
| PUID                              | 서버를 실행할 유저의 UID (`id -u` 명령어로 확인 가능)              | `1000`                                            | 1~                                                                                          | 0.1.0       |
| PGID                              | 서버를 실행할 그룹의 GID (`id -g` 명령어로 확인 가능)              | `1000`                                            | 1~                                                                                          | 0.1.0       |
| REPO_URL                          | 설치할 서버의 URL                                                  | `https://github.com/jh1950/generative_agents`     | 원본 프로젝트 및 포크된 버전의 URL                                                          | 0.4.0       |
| _**[AUTO_UPDATE](#auto_update)**_ | 서버 실행 전 서버 업데이트 확인 및 진행                            | `false`                                           | boolean                                                                                     | 0.2.0       |
| FRONTEND_ROOT                     | 프론트엔드 루트 경로                                               | `environment/frontend_server`                     | `path`, `./path`, `/path`                                                                   | 0.4.0       |
| CONFIG_FILE                       | 프론트엔드 설정 파일 경로 (프론트엔드 루트 기준)                   | any1/any2.py, any1/any2/local.py인 경우 자동 탐지 | `path/file.py`, `./path/file.py`, `/path/file.py`                                           | 0.4.0       |
| SYNC_TZ                           | 프론트엔드 타임존을 컨테이너 타임존과 동기화                       | `true`                                            | boolean                                                                                     | 0.3.1       |
| ALLOWED_HOSTS\*                   | 프론트엔드 접속 허용 IP를 설정 (쉼표로 구분하여 여러 값 설정 가능) | [컨테이너 내부 IP](#웹-접속)                      | `IP`, `IP, Domain, ...`, `manual`                                                           | 0.1.0       |
| BACKEND_ROOT                      | 백엔드 루트 경로                                                   | `reverie/backend_server`                          | `path`, `./path`, `/path`                                                                   | 0.5.0       |
| CUSTOM_UTILS                      | 커스텀 `utils.py` 파일 사용 (`BACKEND_ROOT` 폴더 내 직접 생성)     | false                                             | boolean                                                                                     | 0.5.0       |
| OPENAI_API_KEY                    | OpenAI API Key, (`CUSTOM_UTILS` 값이 `false`일 경우 사용)          | -                                                 | `string`                                                                                    | 0.5.0       |
| OPENAI_API_OWNER                  | OpenAI API Key 소유자 (`CUSTOM_UTILS` 값이 `false`일 경우 사용)    | -                                                 | `string`                                                                                    | 0.5.0       |

\* `ALLOWED_HOSTS` 값을 `manual`로 설정 시 `environment/frontend_server/config/settings/local.py` 파일에서 직접 설정할 수 있습니다.

### AUTO_UPDATE

> [!CAUTION]
> 버전 `0.3.1` 이하에서는 변경된 내용이 **임시저장되지 않습니다**.

<!-- markdownlint-disable-line MD028 -->
> [!IMPORTANT]
> 임시 저장된 내용을 복구하기 위해 별도의 **Merge** 작업이 필요할 수 있습니다.

환경 변수 `AUTO_UPDATE` 값을 `true`로 사용할 경우, 업데이트 진행 시 내용이 변경된 파일들은 모두 임시 저장됩니다.

임시 저장된 내용은 아래 명령어로 복구가 가능합니다.

```bash
git stash list # stash@{0}, stash@{1} 형식의 name 확인
git stash apply name
# git stash drop name # 임시 저장 제거
# git stash clear # 임시 저장 모두 제거
```


## 웹 접속

> [!TIP]
> `docker exec generative_agents hostname -i`
> 명령어로 컨테이너 내부 IP를 확인할 수 있습니다.

만약 컨테이너 포트 연결을 `8001:8000`로 설정했다면 다음과 같은 방법으로 접속합니다.

 1. <http://localhost:8001>
 2. <http://컨테이너_내부_IP:8000>


## 백엔드 실행

```bash
docker exec -it generative_agents backend # or reverie
```
