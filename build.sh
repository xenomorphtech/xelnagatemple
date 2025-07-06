#!/bin/bash
podman run -it --rm -v .:/root/node --entrypoint bash erlang_builder -c "echo 'building xelnagatemple..' \
    && cd /root/node \
    && export MIX_ENV=prod \
    && mix deps.get \
    && mix release \
    && cp _build/prod/rel/bakeware/xelnagatemple xnt"
sha256sum xnt
