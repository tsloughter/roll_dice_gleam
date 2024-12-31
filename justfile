default: run

[working-directory: 'client']
build-client:
     gleam run -m lustre/dev build --minify --outdir=../server/priv/static

[working-directory: 'server']
build-server: run-npm
    gleam build

[working-directory: 'server']
run-npm: npm-install
    npm run build

[working-directory: 'server']
npm-install:
    npm install

[working-directory: 'server']
run: build-client build-server
    gleam run

run-collcetor:
    docker compose up -d
