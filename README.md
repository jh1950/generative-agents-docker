# Generative Agents 전용 컨테이너

[![Latest](https://img.shields.io/github/v/release/jh1950/generative-agents-docker?label=Latest)](https://github.com/jh1950/generative-agents-docker/releases)
[![Source Code](https://img.shields.io/badge/GitHub-Source-blue?logo=github)](https://github.com/jh1950/generative-agents-docker)
[![Docker Hub](https://img.shields.io/badge/Docker-Hub-blue?logo=docker)](https://hub.docker.com/r/jh1950/generative-agents-docker)
[![GHCR](https://img.shields.io/badge/GHCR-Package-blue?logo=docker)](https://github.com/jh1950/generative-agents-docker/pkgs/container/generative-agents-docker)

[jh1950/generative_agents](https://github.com/jh1950/generative_agents) 전용 컨테이너입니다.

## 이미지 설치

아래 명령어를 실행합니다.

```bash
docker pull jh1950/generative-agents-docker:latest
```

## 컨테이너 실행

> [!IMPORTANT]
> `-d` 옵션은 데몬 기능으로, 시스템 시작 시 자동으로 컨테이너를 실행합니다.
>
> 컨테이너를 중지하려면 `docker compose down` 명령어를 실행해야 합니다.

[docker-compose.yml](https://github.com/jh1950/generative-agents-docker/blob/main/docker-compose.yml)
파일을 먼저 생성한 후 해당 파일이 위치한 곳에서 아래 명령어를 실행합니다.

```bash
docker compose up -d
```

## 환경 변수

> [!IMPORTANT]
>
> _**이탤릭체**_: 기본값 사용 권장

`docker-compose.yml` 파일에서 설정 가능한 환경 변수 목록입니다.

| 변수명            | 설명                                                                                             | 기본값           | 예시                          | 버전     |
|-------------------|--------------------------------------------------------------------------------------------------|------------------|-------------------------------|----------|
| PUID              | 서버를 실행할 유저의 UID (`id -u` 명령어로 확인 가능)                                            | 1000             | 1~                            | v0.1.0 ~ |
| PGID              | 서버를 실행할 그룹의 GID (`id -g` 명령어로 확인 가능)                                            | 1000             | 1~                            | v0.1.0 ~ |
| _**AUTO_UPDATE**_ | 서버 실행 전 서버 업데이트 확인 및 진행. **기존 파일이 수정된 경우 해당 내용은 모두 사라집니다** | false            | boolean                       | v0.2.0 ~ |
| ALLOWED_HOSTS     | 프론트앤드 접속 허용 IP를 설정 (쉽표로 구분하여 여러 값 설정 가능)                               | 컨테이너 내부 IP | `*`, `IP, Domain`, `manual`\* | v0.1.0 ~ |

\* `ALLOWED_HOSTS` 값을 `manual`로 설정 시 `environment/frontend_server/config/settings/local.py` 파일을 직접 수정할 수 있습니다.
