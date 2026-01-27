FROM ruby:2.4.1

WORKDIR /wraith

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y libfreetype6 libfontconfig1 nodejs libnss3-dev libgconf-2-4 \
    && rm -rf /var/lib/apt/lists/*

# make sure npm does not need sudo: https://docs.npmjs.com/getting-started/fixing-npm-permissions
RUN mkdir /wraith/.npm-global
ENV NPM_CONFIG_PREFIX=/wraith/.npm-global
ENV PATH=/wraith/.npm-global/bin:$PATH

# install with --unsafe-perm because of https://github.com/Medium/phantomjs/issues/707
RUN npm install -g phantomjs-prebuilt casperjs --unsafe-perm
RUN gem install wraith --no-rdoc --no-ri

# install chrome and chromedriver (unzip is needed for installing chromedriver)
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable unzip \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i 's|HERE/chrome"|HERE/chrome" --disable-setuid-sandbox --no-sandbox|g' \
           "/opt/google/chrome/google-chrome" \
    && google-chrome --version

RUN export CHROMEDRIVER_RELEASE=$(curl --location --fail --retry 3 http://chromedriver.storage.googleapis.com/LATEST_RELEASE) \
    && curl --silent --show-error --location --fail --retry 3 --output /tmp/chromedriver_linux64.zip "http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_RELEASE/chromedriver_linux64.zip" \
    && cd /tmp \
    && unzip chromedriver_linux64.zip \
    && rm -rf chromedriver_linux64.zip \
    && mv chromedriver /usr/local/bin/chromedriver \
    && chmod +x /usr/local/bin/chromedriver \
    && chromedriver --version

# Make sure decent fonts are installed. Thanks to http://www.dailylinuxnews.com/blog/2014/09/things-to-do-after-installing-debian-jessie/
RUN echo "deb http://ftp.us.debian.org/debian jessie main contrib non-free" | tee -a /etc/apt/sources.list
RUN echo "deb http://security.debian.org/ jessie/updates contrib non-free" | tee -a /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y ttf-freefont ttf-mscorefonts-installer ttf-bitstream-vera ttf-dejavu ttf-liberation

# Make sure a recent (>6.7.7-10) version of ImageMagick is installed.
RUN apt-get install -y imagemagick

ENTRYPOINT [ "wraith" ]
