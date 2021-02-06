#!/usr/bin/env bats

@test "embedded c" {
  go run xgo.go github.com/karalabe/xgo/tests/embedded_c
  [ "$status" -eq 0 ]
}

@test "embedded cpp" {
  go run xgo.go github.com/karalabe/xgo/tests/embedded_cpp
  [ "$status" -eq 0 ]
}

@test "has mod" {
  skip "this test doesn't yet exist"
  go run xgo.go src.techknowlogick.com/xgo/tests/hasmod
  [ "$status" -eq 0 ]
}

@test "has mod and vendor" {
  skip "this test doesn't yet exist"
  go run xgo.go src.techknowlogick.com/xgo/tests/hasmodandvendor
  [ "$status" -eq 0 ]
}

@test "branches" {
  go run xgo.go --branch memprof github.com/rwcarlsen/cyan/cmd/cyan
  [ "$status" -eq 0 ]
}

@test "eth smoke" {
  go run xgo.go github.com/ethereum/go-ethereum/cmd/geth
  [ "$status" -eq 0 ]
}

@test "gitea smoke" {
  go run xgo.go code.gitea.io/gitea
  [ "$status" -eq 0 ]
}

@test "cockroach smoke" {
  go run xgo.go --targets "darwin-10.6/amd64" github.com/cockroachdb/cockroach
  [ "$status" -eq 0 ]
}