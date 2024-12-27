default: run

[working-directory: 'client']
build-client:
     gleam run -m lustre/dev build --minify --outdir=../server/priv/static

[working-directory: 'server']
build-server:
    gleam build

[working-directory: 'server']
run: build-client build-server
    gleam run

run-collcetor:
    docker compose up -d
