FROM ruby:2.1.2

# some of ruby's build scripts are written in ruby
# we purge this later to make sure our final image uses what we just built
RUN apt-get update
RUN curl -o phantomjs.tar.gz -L https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.8-linux-x86_64.tar.bz2
RUN tar -xvf phantomjs.tar.gz
RUN mv phantomjs-1.9.8-linux-x86_64/bin/phantomjs /usr/bin
RUN echo "export phantomjs=/usr/bin/phantomjs" > .bashrc
RUN apt-get install -y libfreetype6 libfontconfig1
RUN gem install wraith --no-rdoc --no-ri
RUN gem install aws-sdk --no-rdoc --no-ri

ENTRYPOINT [ "wraith" ]
