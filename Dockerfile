FROM staging

CMD ./_build/prod/rel/rust_mq_api/bin/rust_mq_api start
