export MIX_ENV=prod
rm -rf _build
mix deps.get
mix release

cp _build/prod/rel/bakeware/xelnagatemple .
