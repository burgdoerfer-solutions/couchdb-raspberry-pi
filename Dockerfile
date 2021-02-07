FROM balenalib/raspberrypi3:buster AS build

RUN apt-get update \
  && apt-get install -y wget

RUN wget -q http://packages.erlang-solutions.com/debian/erlang_solutions.asc \
  && apt-key add erlang_solutions.asc \
  && apt-get update \
  && rm erlang_solutions.asc

RUN apt-get --no-install-recommends -y install build-essential \
  pkg-config erlang libicu-dev \
  libmozjs185-dev libcurl4-openssl-dev

WORKDIR /usr/src
RUN wget -O ./couchdb.tar.gz https://downloads.apache.org/couchdb/source/3.1.1/apache-couchdb-3.1.1.tar.gz \
  && mkdir couchdb \
  && tar xfvz couchdb.tar.gz -C couchdb --strip-components=1 \
  && rm couchdb.tar.gz

WORKDIR /usr/src/couchdb
RUN ./configure
RUN make release

FROM balenalib/raspberrypi3:buster

RUN apt-get -y update
RUN apt-get --no-install-recommends -y install libmozjs185-1.0 libicu63

COPY --from=build /usr/src/couchdb/rel/couchdb /opt/couchdb

WORKDIR /opt/couchdb
RUN sed -i 's/;bind_address = 127.0.0.1/bind_address = 0.0.0.0/g' etc/local.ini
CMD ["/opt/couchdb/bin/couchdb"]
