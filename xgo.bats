#!/usr/bin/env bats

@test "embedded c" {
  export GO111MODULE=auto
  run go run . --image="${IMAGEID}" ./tests/embedded_c
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "embedded cpp" {
  run go run . --image="${IMAGEID}" ./tests/embedded_cpp
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "has mod" {
  skip "this test doesn't yet exist"
  run go run . --image="${IMAGEID}" src.techknowlogick.com/xgo/tests/hasmod
  [ "$status" -eq 0 ]
}

@test "has mod and vendor" {
  skip "this test doesn't yet exist"
  run go run . --image="${IMAGEID}" src.techknowlogick.com/xgo/tests/hasmodandvendor
  [ "$status" -eq 0 ]
}

# FIXME: does not work, see https://github.com/techknowlogick/xgo/issues/260
#@test "branches" {
#  run go run . --remote https://github.com/rwcarlsen/cyan --branch memprof --targets "linux/amd64" --image="${IMAGEID}" github.com/rwcarlsen/cyan/cmd/cyan
#  echo "$output"
#  [ "$status" -eq 0 ]
#}

@test "eth smoke" {
  git clone --depth 1 https://github.com/ethereum/go-ethereum.git /tmp/eth
  run go run . --targets "linux/amd64" --image="${IMAGEID}" /tmp/eth/cmd/geth
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "gitea smoke" {
  git clone --depth 1 https://github.com/go-gitea/gitea.git /tmp/gitea
  run go run . --image="${IMAGEID}" --targets "darwin-10.6/amd64" -tags 'netgo osusergo sqlite sqlite_unlock_notify' /tmp/gitea
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "vikunja smoke" {
  export vikunja_path=/tmp/vikunja
  git clone --depth 1 https://github.com/go-vikunja/vikunja $vikunja_path
  mkdir -p $vikunja_path/frontend/dist/
  touch $vikunja_path/frontend/dist/index.html
  run go run . --image="${IMAGEID}" --targets "darwin-15/arm64" $vikunja_path
  echo "$output"
  [ "$status" -eq 0 ]
}
