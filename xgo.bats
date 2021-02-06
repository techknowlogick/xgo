#!/usr/bin/env bats

@test "embedded c" {
  run go run xgo.go github.com/techknowlogick/xgo/tests/embedded_c
  [ "$status" -eq 0 ]
}

@test "embedded cpp" {
  run go run xgo.go github.com/techknowlogick/xgo/tests/embedded_cpp
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
  run go run xgo.go --branch memprof github.com/rwcarlsen/cyan/cmd/cyan
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "eth smoke" {
  run go run xgo.go github.com/ethereum/go-ethereum/cmd/geth
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "gitea smoke" {
  run go run xgo.go --targets "darwin-10.6/amd64" code.gitea.io/gitea
  [ "$status" -eq 0 ]
}
