FROM cipher_checker

ENV DISPLAY :99

RUN apt update
RUN apt install -y wget unzip apt-file xvfb
# Install most common chromium dependencies
RUN apt install -y firefox-esr libasound2 libatk1.0-0 libatk-bridge2.0-0 libatspi2.0-0 libcairo2 libcups2 libdbus-1-3 libfontconfig1 libgbm1 libgconf-2-4 libgdk-pixbuf-2.0-0 libglib2.0-0 libgtk2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libpangocairo-1.0-0 libudev0 libxcomposite1 libxcursor1 libxdamage1 libxi6 libxkbcommon0 libxss1 libxtst6 libexif12

RUN apt-file update

RUN echo "127.0.0.1 ba-testing.unsafe.blazed.win" >> /etc/hosts

WORKDIR /app

COPY . .

RUN chmod +x ./entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
