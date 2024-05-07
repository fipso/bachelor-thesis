FROM debian

ENV DISPLAY :99

RUN apt update && apt install -y openssl bsdmainutils wget unzip apt-file xvfb
RUN apt-file update

# Install chrome deps
#RUN apt install -y libglib2.0-dev libnss3 libgconf-2-4 libpangocairo-1.0-0 libxi6 libxcursor-dev libxcomposite-dev libasound2 libxdamage1 libxtst6 libxrandr2 libcups2 libudev0 libgtk2.0-0 libxss1 libatk-bridge2.0-dev libdrm2

RUN mkdir /app
RUN echo "127.0.0.1 ba-testing.unsafe.blazed.win" >> /etc/hosts

WORKDIR /app

COPY . .

RUN chmod +x ./check.sh

ENTRYPOINT ["./check.sh"]
