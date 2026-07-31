# Inception

`Nginx + WordPress + MariaDB`로 구성된 멀티 컨테이너 인프라를 Docker Hub의 완성된 이미지 없이 모두 직접 Dockerfile로 빌드해 구축한 과제입니다.

## 배경

`docker run wordpress`처럼 완성된 이미지를 받아 쓰는 것과, 베이스 이미지(Alpine/Debian)에서부터 필요한 패키지를 설치하고 서비스를 설정해 직접 이미지를 빌드하는 것은 완전히 다른 이해도를 요구합니다. 이 과제는 컨테이너 간 통신을 위한 격리 네트워크 설계, 데이터 영속성을 위한 볼륨 바인딩, 그리고 TLS를 적용한 리버스 프록시 구성까지 실제 프로덕션에 가까운 인프라를 최소 단위로 구축하며 Docker의 내부 동작을 익히는 것이 목적입니다.

## 요구사항

- 3개 컨테이너를 각각의 Dockerfile로 직접 빌드(Docker Hub의 완성 이미지 사용 금지, `alpine`/`debian` 베이스만 허용)
- Nginx: TLSv1.2/1.3만 허용하는 HTTPS(443) 리버스 프록시(과제 요구사항), php-fpm으로 WordPress와 통신
- WordPress: nginx 없이 php-fpm만 포함해 설치·설정
- MariaDB: nginx 없이 데이터베이스만 단독 구성
- `docker-compose`로 전체 서비스를 오케스트레이션, `.env`로 민감 정보 분리
- WordPress DB와 웹 파일을 위한 볼륨 2종, 컨테이너 간 통신을 위한 격리 브릿지 네트워크
- `network: host`, `--link`, `links:` 사용 금지
- 보너스: FTP(vsftpd), Redis 캐시 등 추가 서비스

## 기술스택

`Docker` · `Dockerfile` · `Docker Compose` · `Nginx`(TLS 리버스 프록시) · `WordPress` + `php-fpm` · `MariaDB` · Docker Network(브릿지) · Volume Bind Mount

## 기능

- **Nginx 컨테이너**: OpenSSL 자가 서명 인증서를 사용해 HTTPS(443)로 서비스(nginx.conf에는 `ssl_protocols TLSv1.3`로 설정), WordPress로는 `fastcgi_pass`로 9000번 포트 프록시
- **WordPress 컨테이너**: `wp-cli`로 사이트 초기 설정(코어 다운로드, DB 연결, 관리자·일반 사용자 생성)을 컨테이너 시작 스크립트에서 자동화, php-fpm을 유닉스 소켓 대신 9000 포트로 리슨하도록 변경해 포그라운드로 실행
- **MariaDB 컨테이너**: 시작 스크립트에서 `CREATE DATABASE/USER IF NOT EXISTS`로 DB·사용자를 멱등하게 초기화, 데이터는 바인드 마운트된 볼륨에 영속
- **네트워크 격리**: `inception`이라는 이름의 전용 브릿지 네트워크로 컨테이너 간 통신을 서비스명 기반 DNS로 해결
- **보너스 서비스(구현되어 있으나 현재 비활성)**: `vsftpd`, `redis`의 Dockerfile·설정은 `srcs/requirements/bonus/`에 작성되어 있으나, `docker-compose.yml`에서는 해당 서비스가 주석 처리되어 현재는 mandatory 3종 컨테이너만 기동됩니다.

## 문제해결 및 예방

**컨테이너 재시작 시 데이터가 초기화되는 문제**
초기 구성에서는 볼륨 없이 컨테이너 내부 경로에 데이터를 저장해, `docker compose down` 후 다시 올리면 DB와 WordPress 콘텐츠가 모두 초기화되는 문제가 있었습니다. 호스트의 특정 디렉토리를 `driver_opts`의 `device`/`bind`로 지정한 named volume으로 MariaDB 데이터 디렉토리와 WordPress 파일 디렉토리를 각각 바인드 마운트해, 컨테이너를 내렸다 올려도 데이터가 유지되도록 고쳤습니다.

**서비스 시작 순서 경쟁 조건(race condition)**
`depends_on`만으로는 컨테이너가 "실행됨" 상태인지만 보장할 뿐 내부 서비스(MariaDB 데몬 등)가 실제로 요청을 받을 준비가 됐는지는 보장하지 않아, WordPress가 MariaDB보다 먼저 연결을 시도해 초기화에 실패하는 경우가 있었습니다. 각 컨테이너의 시작 스크립트(entrypoint)에서 의존 서비스가 응답 가능한 상태가 될 때까지 대기하는 로직을 추가하고, MariaDB/WordPress의 초기화 스크립트가 멱등성을 갖도록(이미 초기화된 상태면 건너뛰도록) 작성해 재시작에도 안전하게 만들었습니다.

**디렉토리 구조 및 상대 경로 문제로 인한 빌드 실패**
`docker-compose.yml`과 각 서비스의 `Dockerfile`/설정 스크립트가 참조하는 상대 경로가 디렉토리 구조 변경 후 어긋나면서 빌드가 실패하는 문제가 반복됐습니다(`fix directory structure`, `fix typepoerrors` 등). `srcs/requirements/<service>/` 하위에 Dockerfile과 설정 스크립트를 일관되게 배치하는 구조로 정리하고, Makefile에서 `docker compose --env-file`과 `-f` 옵션의 경로를 명시적으로 고정해 실행 위치와 무관하게 항상 같은 경로를 참조하도록 만들었습니다.
