#!/usr/bin/env bats

@test "embedded c" {
  export GO111MODULE=auto
  run go run xgo.go --image="${IMAGEID}" ./tests/embedded_c
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "embedded cpp" {
  run go run xgo.go --image="${IMAGEID}" ./tests/embedded_cpp
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "has mod" {
  skip "this test doesn't yet exist"
  run go run xgo.go --image="${IMAGEID}" src.techknowlogick.com/xgo/tests/hasmod
  [ "$status" -eq 0 ]
}

@test "has mod and vendor" {
  skip "this test doesn't yet exist"
  run go run xgo.go --image="${IMAGEID}" src.techknowlogick.com/xgo/tests/hasmodandvendor
  [ "$status" -eq 0 ]
}

@test "branches" {
  run go run xgo.go --remote https://github.com/rwcarlsen/cyan --branch memprof --targets "linux/amd64" --image="${IMAGEID}" github.com/rwcarlsen/cyan/cmd/cyan
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "eth smoke" {
  git clone --depth 1 https://github.com/ethereum/go-ethereum.git /tmp/eth
  run go run xgo.go --targets "linux/amd64" --image="${IMAGEID}" /tmp/eth/cmd/geth
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "gitea smoke" {
  git clone --depth 1 https://github.com/go-gitea/gitea.git /tmp/gitea
  run go run xgo.go --image="${IMAGEID}" --targets "darwin-10.6/amd64" -tags 'netgo osusergo sqlite sqlite_unlock_notify' /tmp/gitea
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "vikunja smoke" {
  git clone --depth 1 https://kolaente.dev/vikunja/api /tmp/vikunja
  run go run xgo.go --image="${IMAGEID}" --targets "darwin-10.6/amd64" /tmp/vikunja
  echo "$output"
  [ "$status" -eq 0 ]
}
