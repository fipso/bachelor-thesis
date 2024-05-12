FROM debian

RUN apt update
RUN apt install -y openssl bsdmainutils jq

RUN mkdir /app

WORKDIR /app

COPY . .

RUN chmod +x ./check.sh

ENTRYPOINT ["./check.sh"]
