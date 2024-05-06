FROM debian

RUN apt update && apt install -y openssl bsdmainutils wget
RUN mkdir /app
RUN echo "127.0.0.1 ba-testing.unsafe.blazed.win" >> /etc/hosts

WORKDIR /app

COPY . .

RUN chmod +x ./check.sh

ENTRYPOINT ["./check.sh"]
