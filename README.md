# Generative Agents 전용 컨테이너

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

## 서버 자동 업데이트 (v0.2.0)

> [!WARNING]
> 기존 파일이 수정된 경우 해당 내용은 모두 사라집니다.

환경 변수 `AUTO_UPDATE` 값을 `true`(기본값: `false`)로 설정한 경우 서버를 실행하기 전 업데이트를 먼저 진행합니다.
