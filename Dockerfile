FROM staging

COPY . /src
WORKDIR /src

RUN MIX_ENV=prod mix release --overwrite
CMD ./_build/prod/rel/rust_mq_api/bin/rust_mq_api start
