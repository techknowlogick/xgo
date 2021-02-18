#!/usr/bin/env bats

@test "embedded c" {
  run go run xgo.go ./tests/embedded_c
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "embedded cpp" {
  skip "TODO: C++ is failing on linux/386, need to look into this"
  run go run xgo.go ./tests/embedded_cpp
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "has mod" {
  skip "this test doesn't yet exist"
  run go run xgo.go src.techknowlogick.com/xgo/tests/hasmod
  [ "$status" -eq 0 ]
}

@test "has mod and vendor" {
  skip "this test doesn't yet exist"
  run go run xgo.go src.techknowlogick.com/xgo/tests/hasmodandvendor
  [ "$status" -eq 0 ]
}

@test "branches" {
  skip "remotes are temporarily disabled due to gomod"
  run go run xgo.go --remote github.com/rwcarlsen/cyan --branch memprof --targets "linux/amd64" github.com/rwcarlsen/cyan/cmd/cyan
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "eth smoke" {
  skip "remotes are temporarily disabled due to gomod"
  run go run xgo.go --remote github.com/ethereum/go-ethereum --targets "linux/amd64" github.com/ethereum/go-ethereum/cmd/geth
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "gitea smoke" {
  git clone https://github.com/go-gitea/gitea.git /tmp/gitea
  run go run xgo.go --targets "darwin-10.6/amd64" -tags 'netgo osusergo sqlite sqlite_unlock_notify' /tmp/gitea
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "vikunja smoke" {
  git clone https://kolaente.dev/vikunja/api /tmp/vikunja
  run go run xgo.go --targets "darwin-10.6/amd64" /tmp/vikunja
  echo "$output"
  [ "$status" -eq 0 ]
}
